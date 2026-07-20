import QtQuick 2.3
// If you're on Qt6, change the import above to just:
//   import QtQuick

// Minimal pseudo-3D straight road strip for a dashboard.
// Single input: vehicleSpeed. No track, no curves, no user control.
//
// PERFORMANCE REFACTOR NOTE:
// The ground layer (sky, grass bands, road surface, lane dividers, edge
// lines) used to be built every 16ms as SVG path strings fed into 4
// QtQuick.Shapes items + a 50-item Repeater of Rectangles. On Qt 5.12's
// Shapes "Generic" renderer (what you get on essentially every embedded/
// ES2 GPU), every PathSvg.path assignment forces a full CPU-side
// re-triangulation of the path and a fresh geometry upload -- that's the
// ~18fps culprit, not "JS in general".
//
// That whole layer is now ONE ShaderEffect (pseudoroad.frag) that computes
// the ground pattern analytically per-pixel by inverting the perspective
// projection (see project()/the shader for the derivation). It has zero
// per-frame JS/CPU geometry cost -- it just reads uPosition, which is a
// live binding to `position`, so it repaints itself automatically as
// position changes. updateStrips() no longer touches ground geometry at
// all; it only still positions the roadside sprites (Image items stay as
// real GPU-composited textured quads -- already cheap, not worth shader-
// izing).
//
// Layers, back to front:
//   ground shader (sky+grass+road+dividers+edges) -> clouds -> horizon
//   stripe -> roadside sprites -> traffic cars

Item {
    id: pseudoRoad

    // --- Public API ---------------------------------------------------
    property real vehicleSpeed: 0     // bind this to your real speed signal
    property real speedToScroll: 60.0  // feel/tuning knob

    // Night mode for sprites: swaps each sprite's source image to a
    // pre-made "night" version (if the def provides one) instead of
    // tinting at runtime. No shader cost -- it's just picking which
    // texture gets bound, same as any other source change.
    property bool nightMode: false

    // Roadside sprites. Each entry: { source, side, width, height, mirror,
    //                                 interval, offset, sideGap }.
    //   source:   a url/path to your .png
    //   side:     "left", "right", or a number (-1 = left, 1 = right)
    //             omit entirely to auto-alternate left/right
    //   width/height: optional per-sprite size at the nearest segment
    //             (scale = 1); falls back to spriteBaseWidth/spriteBaseHeight
    //   mirror:   optional bool override; default auto-mirrors on the left
    //   interval: optional -- how many segments between repeats of THIS
    //             sprite specifically. Smaller = more condensed/denser.
    //             Falls back to spriteInterval if omitted.
    //   offset:   optional phase shift (in segments) so this sprite's
    //             occurrences don't line up with segment 0 -- useful when
    //             mixing several densities so they don't all coincide.
    //   sideGap:  optional per-sprite distance from the road edge.
    //             Falls back to spriteSideGap if omitted.
    //   yOffset:  optional vertical nudge (pixels, at the nearest segment/
    //             scale 1). Positive moves the sprite DOWN, negative moves
    //             it UP. Falls back to spriteYOffset if omitted. Useful
    //             when a .png has empty padding at the bottom, making the
    //             object look like it's floating above the ground line.
    //   nightSource: optional url to a pre-made dark/silhouette version
    //             of this sprite. Used instead of "source" whenever
    //             nightMode is true. If omitted, falls back to "source"
    //             even in night mode (so you can convert art gradually).
    property var spriteDefs: []
    property real spriteBaseWidth: (86 * 6)    // fallback size if a def omits width
    property real spriteBaseHeight: (168 * 6)  // fallback size if a def omits height
    property int spriteInterval: 6             // default segment gap if a def omits interval
    property real spriteSideGap: 100           // default road-edge gap if a def omits sideGap
    property real spriteYOffset: 0             // default vertical nudge if a def omits yOffset
    property color skyColorTop: "#0092FB"          // top of the sky gradient
    property color skyColorBottom: "#8DCFFF"       // bottom of the sky
    property color roadColorOn: "#949494"          // road surface on "on" segments
    property color roadColorOff: "#9c9c9c"         // road surface on "off" segments
    property color terrainColorOn: "#efdece"       // grass/sand on "on" segments   
    property color terrainColorOff: "#e6d6c5"      // grass/sand on "off" segments

    // Traffic cars. Unlike spriteDefs (fixed points in the world that you
    // simply approach), each car has its OWN persistent world position
    // that advances every tick at its own speed -- so its apparent
    // distance depends on the gap between vehicleSpeed and the car's
    // speed, not on where it sits in the segment grid.
    //
    // Each entry: { source, nightSource, width, height, mirror, lane,
    //               speed, count }.
    //   source/nightSource/width/height/mirror: same meaning as spriteDefs.
    //             width/height fall back to trafficBaseWidth/trafficBaseHeight.
    //   lane:     "left", "center", "right", "random" (re-rolled every
    //             spawn/respawn), or a raw fraction of road width (e.g.
    //             0.2). Defaults to "center" if omitted.
    //   speed:    this car's own forward speed, in the SAME units as
    //             vehicleSpeed. speed < vehicleSpeed: you catch up and
    //             pass it. speed > vehicleSpeed: it pulls away toward the
    //             horizon. speed === vehicleSpeed: constant apparent gap,
    //             just like real highway traffic pacing you. Defaults to 0
    //             (a "stalled" car you always approach at your own speed).
    //   speedVariance: optional fraction (e.g. 0.15 = +/-15%). Each car
    //             instance gets its own randomized speed within this
    //             range, re-rolled on every respawn, so clones of the
    //             same def don't all move in lockstep.
    //   scalePercent: optional per-car size multiplier as a percentage
    //             (100 = normal size, 50 = half size, 150 = 1.5x).
    //             Applied on TOP of the normal distance-based perspective
    //             scale -- it doesn't replace it, just scales the whole
    //             car bigger/smaller at every distance. Falls back to
    //             trafficScalePercent if omitted.
    //   count:    how many simultaneous instances of this car to keep
    //             alive/cycling at once. Defaults to 1.
    property var trafficDefs: []
    property real trafficBaseWidth: (86 * 6)
    property real trafficBaseHeight: (168 * 6)
    property real trafficYOffset: 0
    property real trafficScalePercent: 100   // 100 = normal size; default if a def omits scalePercent
    // Below this perspective scale (near the horizon), a car is hidden
    // entirely instead of rendering as a barely-visible speck. Raise this
    // if cars still seem to "hang around" too long near the horizon;
    // lower it if they're disappearing too abruptly/early.
    property real trafficMinScale: 0.05
    // How much random distance-jitter gets added when a car respawns at
    // the far edge, on top of maxVisibleZ. Wider range = less obviously
    // "on a cycle."
    property real trafficRespawnJitter: segmentLength * 10

    // Cloud cover layer: a horizontally-tiling image that continuously
    // drifts left-to-right, independent of vehicleSpeed (clouds move
    // whether the car is stopped or not). For a seamless loop, the
    // source image's left and right edges should match up visually --
    // otherwise you'll see a faint seam once per loop.
    property url cloudSource: ""                   // leave empty to disable
    property real cloudWidth: width                // on-screen width of ONE tile
    property real cloudHeight: height * 0.16
    property real cloudTopOffset: height * 0.07
    property real cloudSpeed: 40                    // px/sec, positive = left-to-right
    property real cloudLayerOpacity: 0.9
    property url secondLayerSource: ""  //Second background layer
    property real secondLayerWidth: 1536
    // --------------------------------------------------------------------

    //Horizon stripe image
    property url horizonStripeSource: ""

    // Total pooled sprite slots needed: each def gets its own worst-case
    // simultaneous count based on ITS OWN interval, summed together.
    readonly property int spriteSlotCount: computeSpriteSlotCount()
    function computeSpriteSlotCount() {
        var total = 0
        for (var k = 0; k < spriteDefs.length; k++) {
            var iv = (spriteDefs[k].interval !== undefined) ? spriteDefs[k].interval : spriteInterval
            total += Math.ceil(numLines / Math.max(iv, 1)) + 1
        }
        return total
    }

    // Total pooled traffic-car slots: sum of each def's requested count
    // (defaulting to 1 if omitted).
    readonly property int trafficSlotCount: computeTrafficSlotCount()
    function computeTrafficSlotCount() {
        var total = 0
        for (var k = 0; k < trafficDefs.length; k++) {
            total += (trafficDefs[k].count !== undefined) ? trafficDefs[k].count : 1
        }
        return total
    }
    //Change for chonk loading
    readonly property int numLines: 50
    readonly property real horizonY: height * 0.42
    property string laneMarkingColor: "#ffffff"
    property real laneMarkingWidthNear: 35
    property bool showLaneDividers: true

    // Edge lines running along the road's outer boundary. Unlike the
    // center dividers (which toggle visibility on/off for a dash), these
    // stay visible every segment and instead toggle POSITION: "on"
    // segments get pushed inward by their own width, "off" segments sit
    // flush against the true edge -- giving the classic alternating
    // in/out "curb" look.
    property bool showEdgeLines: true
    property string edgeMarkingColor: laneMarkingColor
    property real edgeMarkingWidthNear: 40

    // zNear = world distance of the closest segment (bottom of screen).
    // roadWidthNear = pixel width of the road at that closest segment.
    // These are just "feel" constants -- tune to taste.
    readonly property real zNear: 300.0
    readonly property real roadWidthNear: width * 2.7
    readonly property real segmentLength: 200.0

    // Furthest world distance our segment table actually covers -- used
    // as the traffic spawn/cull boundary so cars appear/disappear right
    // around the horizon instead of popping in mid-screen.
    readonly property real maxVisibleZ: zNear + numLines * segmentLength

    property real position: 0

    // Internal: live traffic car state (worldZ + lane per active car).
    // Rebuilt whenever trafficDefs changes.
    property var _trafficState: []

    // --- Ground layer: sky + grass + road + lane dividers + edge lines ---
    // Replaces what used to be: sky Rectangle, grassStrips Repeater,
    // roadShapeOn, roadShapeOff, laneDividerShape, edgeLineShape.
    // See pseudoroad.frag for the per-pixel math. Everything here is a
    // live property binding -- there is no per-frame JS work for this
    // layer at all; it repaints itself off of `position` automatically.
    ShaderEffect {
        id: groundShader
        anchors.fill: parent

        property real uWidth: width
        property real uHeight: height
        // IMPORTANT: uPosition must NOT be the raw, ever-growing
        // pseudoRoad.position. This device's driver doesn't define
        // GL_FRAGMENT_PRECISION_HIGH, so every "highp" in the fragment
        // shader silently downgrades to mediump -- which only guarantees
        // ~10 bits of mantissa (exact integers only up to ~1024). Left
        // unwrapped, position blows past that within a few seconds of
        // driving and floor()/mod() in the shader start producing
        // garbage -- that's the "works for 5s, then freezes into two
        // fixed lines" symptom.
        //
        // Fix: wrap it on the CPU (JS does real double precision, so
        // this is exact) to a small window before it ever reaches the
        // GPU. The wrap period must be a multiple of 2*segmentLength so
        // the on/off parity pattern doesn't skip or jump at the wrap --
        // shifting the shader's numerator by an exact even multiple of
        // segmentLength changes floor()/mod(...,2.0) by nothing at all.
        property real uPosition: pseudoRoad.position % (pseudoRoad.segmentLength * 2.0)
        property real uZNear: pseudoRoad.zNear
        property real uSegmentLength: pseudoRoad.segmentLength
        property real uHorizonY: pseudoRoad.horizonY
        property real uRoadWidthNear: pseudoRoad.roadWidthNear
        property real uLaneMarkingWidthNear: pseudoRoad.laneMarkingWidthNear
        property real uEdgeMarkingWidthNear: pseudoRoad.edgeMarkingWidthNear
        property real uShowLaneDividers: pseudoRoad.showLaneDividers ? 1.0 : 0.0
        property real uShowEdgeLines: pseudoRoad.showEdgeLines ? 1.0 : 0.0

        property color uSkyColorTop: pseudoRoad.skyColorTop
        property color uSkyColorBottom: pseudoRoad.skyColorBottom
        property color uRoadColorOn: pseudoRoad.roadColorOn
        property color uRoadColorOff: pseudoRoad.roadColorOff
        property color uTerrainColorOn: pseudoRoad.terrainColorOn
        property color uTerrainColorOff: pseudoRoad.terrainColorOff
        property color uLaneMarkingColor: pseudoRoad.laneMarkingColor
        property color uEdgeMarkingColor: pseudoRoad.edgeMarkingColor

        // ShaderEffect.fragmentShader wants literal GLSL source text, not
        // a file path -- so we read the .frag file's contents in with a
        // synchronous XMLHttpRequest (the standard QML idiom for this).
        // Qt.resolvedUrl() resolves "pseudoroad.frag" relative to this
        // .qml file's location; switch to "qrc:/pseudoroad.frag" if you
        // bundle it as a Qt resource instead.
        fragmentShader: pseudoRoad.loadShaderSource(Qt.resolvedUrl("pseudoroad.frag"))
    }

    // Drifting cloud cover. Two copies of the source image placed
    // back-to-back, continuously animated from x=-cloudWidth to x=0 and
    // looping -- reads as one endless band crawling left to right.
    // Uses a plain NumberAnimation (not the JS update loop) since this
    // should keep drifting even when vehicleSpeed is 0.
    Item {
        id: cloudClip
        x: 0
        y: pseudoRoad.cloudTopOffset
        width: pseudoRoad.width
        height: pseudoRoad.cloudHeight
        clip: true
        visible: pseudoRoad.cloudSource != ""
        opacity: pseudoRoad.cloudLayerOpacity
        Row{
            id:backImage
            x: -pseudoRoad.secondLayerWidth
            y:-25
            Image{
                source: pseudoRoad.secondLayerSource
            }
            Image{
                source: pseudoRoad.secondLayerSource
            }
            NumberAnimation on x {
                running: pseudoRoad.secondLayerSource != "" && pseudoRoad.cloudSpeed !== 0
                from: -pseudoRoad.secondLayerWidth
                to: 0
                duration: Math.abs(pseudoRoad.secondLayerWidth / Math.max(pseudoRoad.cloudSpeed, 0.001)) * 1500
                loops: Animation.Infinite
            }
        }
        Row {
            id: cloudRow
            x: -pseudoRoad.cloudWidth

            Image {
                width: pseudoRoad.cloudWidth
                height: pseudoRoad.cloudHeight
                source: pseudoRoad.cloudSource
                fillMode: Image.Stretch
            }
            Image {
                width: pseudoRoad.cloudWidth
                height: pseudoRoad.cloudHeight
                source: pseudoRoad.cloudSource
                fillMode: Image.Stretch
            }

            NumberAnimation on x {
                running: pseudoRoad.cloudSource != "" && pseudoRoad.cloudSpeed !== 0
                from: -pseudoRoad.cloudWidth
                to: 0
                duration: Math.abs(pseudoRoad.cloudWidth / Math.max(pseudoRoad.cloudSpeed, 0.001)) * 1000
                loops: Animation.Infinite
            }
        }
        
    }
    Image{
        id: horizonStripe
        source: horizonStripeSource
        x: 0; y: 256; z: 1
    }

    Repeater {
        id: sprites
        model: pseudoRoad.spriteSlotCount
        delegate: Image {
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    // Traffic cars: same pooled Image approach as sprites, but positioned
    // every frame from _trafficState's persistent worldZ rather than
    // being derived from the segment loop.
    Repeater {
        id: trafficCars
        model: pseudoRoad.trafficSlotCount
        delegate: Image {
            visible: false
            fillMode: Image.PreserveAspectFit
            smooth: true
        }
    }

    // Synchronously reads a local/qrc file's text content -- used once at
    // binding-evaluation time to pull pseudoroad.frag's GLSL source into
    // the fragmentShader property (which requires literal source text,
    // not a file path). Runs once, not per-frame, so the sync XHR here
    // costs nothing at runtime.
    function loadShaderSource(url) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url, false)
        xhr.send()
        return xhr.responseText
    }

    // Projects one world distance z to a screen Y and a 0..1 scale factor.
    // scale = zNear/z: 1 at the closest segment, shrinking toward 0 with
    // distance -- this 1/z falloff is what makes screenY bunch up near
    // the horizon instead of spacing out evenly, and what sprites use to
    // shrink/converge as they "approach" from the horizon.
    //
    // The ground shader inverts exactly this function (solve for z given
    // screenY) to get its per-pixel segment index -- see pseudoroad.frag.
    function project(z) {
        var scale = zNear / z
        var screenY = horizonY + (height - horizonY) * scale
        return { screenY: screenY, scale: scale }
    }

    // Resolves a spriteDefs[].side entry to -1 (left) or 1 (right).
    // Accepts "left"/"right", a raw number, or omission (auto-alternate
    // based on how many times this def has been placed so far).
    function resolveSide(def, placementIndex) {
        if (typeof def.side === "number") return def.side
        if (def.side === "left") return -1
        if (def.side === "right") return 1
        return (placementIndex % 2 === 0) ? -1 : 1
    }

    // Resolves whether a placed sprite should be horizontally mirrored.
    // If the def specifies "mirror" explicitly, that always wins.
    // Otherwise, default to mirroring on the left side -- most sprite art
    // (trees, signs) is drawn facing one direction, and flipping it for
    // the opposite side of the road is the classic pseudo-3D-racer trick.
    function resolveMirror(def, side) {
        if (def.mirror !== undefined) return def.mirror
        return side === -1
    }

    // Resolves a trafficDefs[].lane entry to a fraction of the road's
    // half-width: -1/3 = left lane center, 0 = center lane, 1/3 = right
    // lane center (matching the 3-equal-lanes math used for edge lines
    // and dividers elsewhere in this file). "random" picks one of the
    // three each time this is called (spawn and every respawn). A raw
    // number is used as-is.
    function resolveLaneFrac(def) {
        if (typeof def.lane === "number") return def.lane
        if (def.lane === "left") return -1 / 3
        if (def.lane === "right") return 1 / 3
        if (def.lane === "random") {
            var options = [-1 / 3, 0, 1 / 3]
            return options[Math.floor(Math.random() * options.length)]
        }
        return 0   // "center" or omitted
    }

    // Resolves a car's actual speed for this spawn, applying speedVariance
    // (if the def specifies one) as a one-time random roll rather than a
    // per-frame fluctuation -- each car keeps a consistent pace for the
    // duration of its pass, then gets a fresh roll on its next respawn.
    function resolveCarSpeed(def) {
        var base = (def.speed !== undefined) ? def.speed : 0
        var variance = def.speedVariance
        if (!variance) return base
        var jitter = (Math.random() * 2 - 1) * variance
        return base * (1 + jitter)
    }

    // (Re)builds the persistent traffic car state from trafficDefs.
    // Spreads each def's cars out RANDOMLY across the visible depth (not
    // evenly) so they don't spawn looking obviously arranged.
    function initTraffic() {
        var state = []
        for (var k = 0; k < trafficDefs.length; k++) {
            var def = trafficDefs[k]
            var count = (def.count !== undefined) ? def.count : 1
            for (var c = 0; c < count; c++) {
                var spread = zNear + Math.random() * maxVisibleZ
                state.push({
                    defIndex: k,
                    worldZ: position + spread,
                    laneFrac: resolveLaneFrac(def),
                    speed: resolveCarSpeed(def)
                })
            }
        }
        _trafficState = state
    }

    onTrafficDefsChanged: initTraffic()

    function updateTraffic() {
        var dtSeconds = 16 / 1000
        var slot0 = 0

        for (var k = 0; k < _trafficState.length; k++) {
            var car = _trafficState[k]
            var def = trafficDefs[car.defIndex]
            if (!def) continue

            car.worldZ += car.speed * speedToScroll * dtSeconds

            var relZ = car.worldZ - position

            // Recycle: either passed behind the camera, or drifted too
            // far ahead to matter -- respawn at the far edge of the
            // visible range so traffic keeps cycling indefinitely.
            // Lane and speed get re-rolled here too, so a car doesn't
            // repeat the exact same lane/pace every single pass.
            if (relZ < zNear * 0.6 || relZ > maxVisibleZ * 1.05) {
                car.worldZ = position + maxVisibleZ + Math.random() * trafficRespawnJitter
                car.laneFrac = resolveLaneFrac(def)
                car.speed = resolveCarSpeed(def)
                relZ = car.worldZ - position
            }

            var slot = trafficCars.itemAt(slot0)
            slot0++
            if (!slot) continue

            if (relZ < zNear * 0.6) {
                slot.visible = false
                continue
            }

            var p = project(relZ)

            // Hide entirely once it's shrunk down near the horizon --
            // otherwise it lingers forever as a barely-visible dot instead
            // of actually vanishing.
            if (p.scale < trafficMinScale) {
                slot.visible = false
                continue
            }

            var scaleMult = ((def.scalePercent !== undefined) ? def.scalePercent : trafficScalePercent) / 100
            var baseW = (def.width !== undefined) ? def.width : trafficBaseWidth
            var baseH = (def.height !== undefined) ? def.height : trafficBaseHeight
            var sw = Math.max(baseW * p.scale * scaleMult, 1)
            var sh = Math.max(baseH * p.scale * scaleMult, 1)
            var yOff = (def.yOffset !== undefined) ? def.yOffset : trafficYOffset
            var centerX = width / 2 + car.laneFrac * roadWidthNear * p.scale

            slot.source = (nightMode && def.nightSource !== undefined) ? def.nightSource : def.source
            slot.mirror = (def.mirror !== undefined) ? def.mirror : false
            slot.width = sw
            slot.height = sh
            slot.x = centerX - sw / 2
            slot.y = p.screenY - sh + yOff * p.scale * scaleMult
            slot.visible = true

            // Same depth-based z trick as roadside sprites: map relZ onto
            // the same j-equivalent scale so cars and trees/signs sort
            // correctly against each other, not just against other cars.
            var jEquiv = (relZ - zNear) / segmentLength
            jEquiv = Math.max(0, Math.min(numLines, jEquiv))
            slot.z = (numLines - jEquiv) + 1
        }

        for (; slot0 < trafficSlotCount; slot0++) {
            var unusedCar = trafficCars.itemAt(slot0)
            if (unusedCar) unusedCar.visible = false
        }
    }

    // NOTE: this used to also rebuild the SVG path strings for the road
    // surface, lane dividers, and edge lines (roadOnParts/roadOffParts/
    // dividerParts/edgeParts + a 50-item grass Repeater loop). All of that
    // is now handled by groundShader/pseudoroad.frag with zero per-frame
    // JS cost, driven purely off the `position` binding. This function's
    // only remaining job is placing the roadside sprite Image pool, which
    // still needs the per-segment sample table since sprites are discrete
    // textured items, not shader-drawn.
    function updateStrips() {
        // `position` grows forever as the vehicle drives -- wrap it back
        // down periodically rather than let it climb unbounded for the
        // life of the dashboard. The wrap chunk is a multiple of
        // segmentLength AND divisible by every small interval (1-16),
        // so baseIndex's parity/modulo behavior (road stripes, lane
        // dividers, and any spriteDefs interval up to 16) comes out
        // exactly the same on the other side of the wrap -- no visible
        // hitch. If you ever use a sprite interval that doesn't divide
        // 720720, there's a theoretical one-frame glitch right at the
        // wrap instant, which happens roughly once every wrapChunk
        // world-units of driving (practically: extremely rare).
        if (position > 50000000) {
            var wrapChunk = segmentLength * 720720
            position -= Math.floor(position / wrapChunk) * wrapChunk
        }

        var scrollOffset = position % segmentLength
        var baseIndex = Math.floor(position / segmentLength)

        // Sample one segment boundary further than we draw, so every
        // visible strip can compute its far edge from the next sample.
        var samples = []
        for (var i = 0; i <= numLines; i++) {
            var z = zNear + i * segmentLength - scrollOffset
            samples.push(project(z))
        }

        var spriteSlot = 0

        for (var j = 0; j < numLines; j++) {
            var near = samples[j]

            // roadside sprites: each def is checked independently against
            // its OWN interval/offset, so a dense "condensed" sprite (e.g.
            // water reeds every 2 segments) and a sparse one (e.g. trees
            // every 6) can coexist without one forcing the other's rhythm
            for (var d = 0; d < spriteDefs.length; d++) {
                var def = spriteDefs[d]
                var interval = (def.interval !== undefined) ? def.interval : spriteInterval
                var phase = def.offset !== undefined ? def.offset : 0

                if ((baseIndex + j + phase) % Math.max(interval, 1) !== 0) continue

                var slot = sprites.itemAt(spriteSlot)
                spriteSlot++
                if (!slot) continue

                var placementIndex = Math.floor((baseIndex + j + phase) / Math.max(interval, 1))
                var side = resolveSide(def, placementIndex)
                var mirror = resolveMirror(def, side)
                var gap = (def.sideGap !== undefined) ? def.sideGap : spriteSideGap
                var yOff = (def.yOffset !== undefined) ? def.yOffset : spriteYOffset
                var baseW = (def.width !== undefined) ? def.width : spriteBaseWidth
                var baseH = (def.height !== undefined) ? def.height : spriteBaseHeight
                var sw = Math.max(baseW * near.scale, 1)
                var sh = Math.max(baseH * near.scale, 1)
                var centerX = width / 2 + side * (roadWidthNear / 2 + gap) * near.scale

                slot.source = (nightMode && def.nightSource !== undefined) ? def.nightSource : def.source
                slot.mirror = mirror
                slot.width = sw
                slot.height = sh
                slot.x = centerX - sw / 2
                slot.y = near.screenY - sh + yOff * near.scale
                slot.visible = true
                // Nearer segments (small j) must always paint over farther
                // ones, regardless of which def or pool slot placed them --
                // pool-slot order alone doesn't reflect depth, so we set
                // z explicitly. +1 keeps every sprite above the ground
                // shader (which sits at the default z of 0).
                slot.z = (numLines - j) + 1
            }
        }

        // hide any pooled sprite slots we didn't use this frame
        for (; spriteSlot < spriteSlotCount; spriteSlot++) {
            var unused = sprites.itemAt(spriteSlot)
            if (unused) unused.visible = false
        }
    }

    Component.onCompleted: {
        initTraffic()
        updateStrips()
    }

    Timer {
        interval: 16
        running: pseudoRoad.vehicleSpeed > 0
        repeat: true
        onTriggered: {
            pseudoRoad.position += pseudoRoad.vehicleSpeed * (pseudoRoad.speedToScroll * 16 / 1000)
            pseudoRoad.updateStrips()
        }
    }

    // Traffic runs on its OWN timer, independent of vehicleSpeed. A car's
    // worldZ advances at its own pace regardless of whether the player is
    // moving -- so cars with speed > 0 correctly keep driving away into
    // the horizon even while you're sitting still.
    Timer {
        interval: 16
        running: pseudoRoad.trafficDefs.length > 0
        repeat: true
        onTriggered: pseudoRoad.updateTraffic()
    }
}
