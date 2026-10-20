/* ============================================================
   CONDUCTOR — Rev H · motion
   Two effects, one idea: numbers made of dust.

   Conductor.dust(canvas)   dust board behind a hero
   Conductor.settle(el)     split-flap settle on a .flap figure

   A board of square cells, like a dot-matrix departure board seen
   through dust. Every cell flickers between dim levels on its own slow
   clock, densest through the middle band, with a few bright sparks.
   Every few seconds a time (always a valid 24-hour HH:MM) arrives the way a
   split-flap schedule board changes: each character flips through
   digits, top half first, with a dark hinge across its middle, and the
   characters land left to right. Every in-between frame is a valid time. It holds, then erodes left to right
   like sand off a ledge, each cell flaring once before it goes dim.
   Nothing falls in columns; this is not the Matrix.
   Reads --sodium and --text so it follows the shade.
   Honors prefers-reduced-motion: one still frame with a figure held.
   Spec: references/conductor.md
   ============================================================ */
(function (root) {
  var reduce = root.matchMedia && root.matchMedia('(prefers-reduced-motion: reduce)').matches;
  function rnd(n) { return Math.floor(Math.random() * n); }
  function pad(n) { return (n < 10 ? '0' : '') + n; }
  // Always a valid 24-hour time, HH:MM.
  function figure() { return pad(rnd(24)) + ':' + pad(rnd(60)); }
  // Digits a character may show while it flips, so that every frame of the
  // board reads as a valid time too. The hour tens cycles 0-1 and only lands
  // on 2; once it can be 2 the hour ones cycles 0-3; minutes tens 0-5.
  function flipRange(text, k) {
    if (k === 0) return 2;
    if (k === 1) return text[0] === '2' ? 4 : 10;
    if (k === 3) return 6;
    return 10;
  }
  function dust(canvas, opts) {
    opts = opts || {};
    var cell_ = opts.cell || 12, dot = cell_ - 3, pad = (cell_ - dot) / 2, FLIP = 0.11;
    var region = opts.region || [0.5, 0.97], spark = opts.spark == null ? 0.018 : opts.spark;
    var ctx = canvas.getContext('2d'), w = 0, h = 0, cols = 0, rows = 0;
    var lvl, tgt, due, cache = {}, raf = 0, last = 0, clock = 0, form = null, nextForm = 1;
    var sodium = '#F2A33C', ink = '#DADBDE', seam = '#130B0B';

    function readColors() {
      var cs = getComputedStyle(canvas);
      sodium = cs.getPropertyValue('--sodium').trim() || sodium;
      ink = cs.getPropertyValue('--text').trim() || ink;
      seam = cs.getPropertyValue('--bg').trim() || seam;
    }
    // Density envelope: thick through the middle band, thin at top and bottom.
    function band(r) { var y = r / rows; return Math.pow(Math.sin(Math.PI * y), 0.8); }
    function pick(i) {
      var r = (i / cols) | 0, b = band(r), x = Math.random();
      if (x < spark * b) return 0.9;               // spark
      if (x > 0.15 + 0.45 * b) return 0;           // empty
      return Math.pow(Math.random(), 1.8) * 0.26 * b;
    }
    function resize() {
      var dpr = Math.min(root.devicePixelRatio || 1, 2);
      w = canvas.clientWidth; h = canvas.clientHeight;
      canvas.width = w * dpr; canvas.height = h * dpr;
      ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
      cols = Math.ceil(w / cell_); rows = Math.ceil(h / cell_);
      var n = cols * rows;
      lvl = new Float32Array(n); tgt = new Float32Array(n); due = new Float32Array(n);
      for (var i = 0; i < n; i++) { tgt[i] = lvl[i] = pick(i); due[i] = Math.random() * 3; }
      form = null; nextForm = clock + 0.8;
    }
    // Rasterize one glyph at board resolution: one canvas pixel per cell.
    // Returns cell offsets [col, row] inside the character's box.
    function glyphCells(ch, size, cw, base) {
      var key = ch + '|' + size + '|' + base;
      if (cache[key]) return cache[key];
      var off = document.createElement('canvas'), o = off.getContext('2d');
      off.width = cw; off.height = rows;
      o.font = '500 ' + size + 'px "DM Mono", ui-monospace, monospace';
      o.textAlign = 'center'; o.textBaseline = 'middle';
      o.fillText(ch, cw / 2, base);
      var d = o.getImageData(0, 0, cw, rows).data, out = [];
      for (var r = 0; r < rows; r++)
        for (var c = 0; c < cw; c++)
          if (d[(r * cw + c) * 4 + 3] > 110) out.push([c, r]);
      return (cache[key] = out);
    }
    // A figure is a row of split-flap characters. Each one flips through
    // random digits (top half drops first, then the bottom), lands left to
    // right, holds, then erodes left to right like sand off a ledge.
    function startForm() {
      if (w < 700) { nextForm = clock + 5; return; }
      var c0 = Math.floor(cols * region[0]), c1 = Math.floor(cols * region[1]), span = c1 - c0;
      var text = figure();
      var size = Math.round(Math.min(rows * 0.5, span / (text.length * 0.64)));
      if (size < 7) { nextForm = clock + 5; return; }
      var cw = Math.ceil(size * 0.62), base = Math.round(rows * (0.42 + Math.random() * 0.16));
      var x0 = c0 + Math.floor((span - cw * text.length) / 2);
      var top = base - Math.ceil(size * 0.42), mid = base, bot = base + Math.ceil(size * 0.42);
      cache = {};
      var chars = Array.from(text, function (ch, k) {
        var digit = /[0-9]/.test(ch), seq = [];
        var n = digit ? 5 + k * 2 + rnd(4) : 0;
        for (var j = 0; j < n; j++) seq.push(String(rnd(flipRange(text, k))));
        seq.push(ch);
        return { x: x0 + k * cw, seq: seq, start: clock + 0.15 * k, done: false };
      });
      var landed = clock + 0.15 * text.length + FLIP * Math.max.apply(null, chars.map(function (c) { return c.seq.length; }));
      var hold = landed + 2.6;
      chars.forEach(function (c) {
        c.cells = glyphCells(c.seq[c.seq.length - 1], size, cw, base).map(function (pt) {
          var i = (pt[1] * cols) + c.x + pt[0];
          var x = (c.x + pt[0] - x0) / (cw * text.length);
          return { i: i, release: hold + x * 1.8 + Math.random() * 0.5, gone: false };
        });
      });
      form = { chars: chars, size: size, cw: cw, base: base, top: top, mid: mid, bot: bot, end: hold + 2.6 };
    }
    function step(dt) {
      clock += dt;
      if (!form && clock >= nextForm) startForm();
      if (form && clock > form.end) { form = null; nextForm = clock + 2 + Math.random() * 3; }
      var k = Math.min(1, dt * 3);
      for (var i = 0; i < lvl.length; i++) {
        if (clock >= due[i]) { tgt[i] = pick(i); due[i] = clock + 0.4 + Math.random() * 3.2; }
        lvl[i] += (tgt[i] - lvl[i]) * k;
      }
      if (form) form.chars.forEach(function (c) {
        c.cells.forEach(function (cl) {
          if (!cl.gone && clock > cl.release) {
            // Eroded: flare once, then fall back to dust.
            cl.gone = true; lvl[cl.i] = 0.95; tgt[cl.i] = pick(cl.i) * 0.6; due[cl.i] = clock + 0.8 + Math.random() * 2;
          }
        });
      });
    }
    function cell(i, a, color) {
      ctx.globalAlpha = a; ctx.fillStyle = color;
      ctx.fillRect((i % cols) * cell_ + pad, ((i / cols) | 0) * cell_ + pad, dot, dot);
    }
    function drawGlyph(c, ch, r0, r1, a) {
      glyphCells(ch, form.size, form.cw, form.base).forEach(function (pt) {
        if (pt[1] >= r0 && pt[1] < r1) cell(pt[1] * cols + c.x + pt[0], a, sodium);
      });
    }
    function draw() {
      ctx.clearRect(0, 0, w, h);
      var box = null;
      if (form) {
        // Quiet the board behind the characters so the flaps read.
        box = { l: form.chars[0].x, r: form.chars[form.chars.length - 1].x + form.cw, t: form.top - 1, b: form.bot + 1 };
      }
      for (var i = 0; i < lvl.length; i++) {
        var a = lvl[i];
        if (a < 0.02) continue;
        if (box) {
          var cx = i % cols, cy = (i / cols) | 0;
          if (cx >= box.l && cx < box.r && cy >= box.t && cy <= box.b && a < 0.9) a *= 0.35;
        }
        cell(i, a, a > 0.7 ? sodium : ink);
      }
      if (!form) { ctx.globalAlpha = 1; return; }
      form.chars.forEach(function (c) {
        var t = clock - c.start;
        if (t < 0) return;
        var n = Math.floor(t / FLIP), frac = (t / FLIP) % 1;
        if (n >= c.seq.length - 1) {
          // Landed: the final glyph, cell by cell until it erodes.
          c.cells.forEach(function (cl) { if (!cl.gone) cell(cl.i, 0.95, sodium); });
        } else {
          // Mid-flip: the new leaf's top half has dropped, the old bottom
          // half still shows until the leaf lands.
          var cur = c.seq[n + 1], prev = n > 0 ? c.seq[n] : null;
          if (frac < 0.5) {
            drawGlyph(c, cur, 0, form.mid, 0.85);
            if (prev) drawGlyph(c, prev, form.mid, rows, 0.6);
          } else {
            drawGlyph(c, cur, 0, rows, 0.85);
          }
        }
        // The hinge: a dark seam across the character's middle.
        ctx.globalAlpha = 0.85; ctx.fillStyle = seam;
        ctx.fillRect(c.x * cell_, form.mid * cell_ - 1, form.cw * cell_ - 3, 2);
      });
      ctx.globalAlpha = 1;
    }
    function still() {
      startForm();
      if (form) form.chars.forEach(function (c) { c.start = -99; });
      clock = 0.5; draw();
    }
    function frame(t) {
      var dt = last ? Math.min((t - last) / 1000, 0.05) : 0;
      last = t; step(dt); draw(); raf = requestAnimationFrame(frame);
    }
    function start() { if (!reduce && !raf) { last = 0; raf = requestAnimationFrame(frame); } }
    function stop() { cancelAnimationFrame(raf); raf = 0; }

    readColors(); resize();
    if (reduce) still(); else start();
    root.addEventListener('resize', function () { resize(); if (reduce) still(); });
    document.addEventListener('visibilitychange', function () { document.hidden ? stop() : start(); });
    function recolor() { readColors(); if (!raf) draw(); }
    new MutationObserver(recolor)
      .observe(document.documentElement, { attributes: true, subtree: true, attributeFilter: ['data-shade', 'data-theme'] });
    if (root.matchMedia) root.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', recolor);
    return { start: start, stop: stop };
  }

  function settle(el, value) {
    value = String(value != null ? value : (el.dataset.value || el.textContent)).trim();
    el.dataset.value = value;
    el.setAttribute('aria-label', value);
    el.textContent = '';
    var leaves = Array.from(value, function (ch) {
      var s = document.createElement('span');
      var digit = /[0-9]/.test(ch);
      s.className = 'leaf' + (digit || /[A-Z]/i.test(ch) ? '' : ' sep');
      s.setAttribute('aria-hidden', 'true');
      s.textContent = ch;
      el.appendChild(s);
      return { el: s, ch: ch, digit: digit };
    });
    if (reduce) return;
    leaves.forEach(function (l, i) {
      if (!l.digit) return;
      var flips = 6 + i * 3 + rnd(4);
      (function tick() {
        if (flips-- <= 0) { l.el.textContent = l.ch; return; }
        l.el.textContent = String(rnd(10));
        setTimeout(tick, 45 + rnd(25));
      })();
    });
  }

  root.Conductor = { dust: dust, settle: settle };
})(window);
