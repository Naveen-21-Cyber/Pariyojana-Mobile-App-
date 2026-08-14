'use strict';

/* ═══════════════════════════════════════════════════════════════════
   PARIYOJANA — Website Script
   Preloader → Cinematic zoom-out → GSAP reveals → Carousel removed
   All interactions, timer demo, BYOK demo, nav, GitHub stars
═══════════════════════════════════════════════════════════════════ */

/* ── GLOBAL STATE ───────────────────────────────────────────────── */
let timerInterval = null;
let timerRunning  = false;
let timerTotal    = 25 * 60;
let timerLeft     = 25 * 60;
let shlokaIdx     = 0;

const SHLOKAS = [
  { s:'योगः कर्मसु कौशलम्',           e:'Excellence in action is true Yoga. — BG 2.50' },
  { s:'कर्मण्येवाधिकारस्ते',             e:'You have a right to your duty, not its fruits. — BG 2.47' },
  { s:'उद्धरेदात्मनात्मानं',              e:'Elevate yourself; do not degrade yourself. — BG 6.5' },
  { s:'नैनं छिन्दन्ति शस्त्राणि',       e:'The soul is unbreakable. Stay resilient. — BG 2.23' },
  { s:'सर्वधर्मान्परित्यज्य',            e:'Surrender doubt and step forward without fear. — BG 18.66' },
];

/* ═══════════════════════════════════════════════════════════════════
   ENTRY POINT — Instant App Initialization
═══════════════════════════════════════════════════════════════════ */
let appInitialized = false;

function launchApp() {
  if (appInitialized) return;
  appInitialized = true;
  initApp();
}

if (document.readyState === 'interactive' || document.readyState === 'complete') {
  launchApp();
} else {
  document.addEventListener('DOMContentLoaded', launchApp);
  window.addEventListener('load', launchApp);
}

/* ═══════════════════════════════════════════════════════════════════
   1. APP INITIALIZATION & GSAP SETUP
═══════════════════════════════════════════════════════════════════ */
function initApp() {
  // Trigger cinematic reveal animation on hero text
  const zoomTarget = document.querySelector('.hero-zoom-target');
  if (zoomTarget) {
    setTimeout(() => {
      zoomTarget.classList.add('zoom-animate');
    }, 60);
  }

  // Initialize all interactive components
  initLenis();
  initGSAP();
  initNav();
  initGitHubStars();
  initTimerDemo();
  initNavToggle();
}

/* ═══════════════════════════════════════════════════════════════════
   3. LENIS SMOOTH SCROLL (Ultra-Smooth 120fps Hardware-Accelerated)
═══════════════════════════════════════════════════════════════════ */
function initLenis() {
  if (typeof Lenis === 'undefined') return;
  const lenis = new Lenis({
    duration: 1.0,
    lerp: 0.1,
    smoothWheel: true,
    wheelMultiplier: 1.0,
    touchMultiplier: 1.0,
    infinite: false,
  });

  window.lenis = lenis;

  // Single unified RAF loop via GSAP ticker
  if (typeof gsap !== 'undefined') {
    gsap.ticker.add((time) => {
      lenis.raf(time * 1000);
    });
    gsap.ticker.lagSmoothing(0);
  } else {
    function raf(time) {
      lenis.raf(time);
      requestAnimationFrame(raf);
    }
    requestAnimationFrame(raf);
  }
}

/* ═══════════════════════════════════════════════════════════════════
   4. GSAP SCROLL REVEALS
═══════════════════════════════════════════════════════════════════ */
function initGSAP() {
  if (typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') {
    // Fallback: reveal all elements immediately
    document.querySelectorAll('.reveal-up,.reveal-left,.reveal-right').forEach(el => {
      el.classList.add('revealed');
    });
    return;
  }

  gsap.registerPlugin(ScrollTrigger);

  // Sync GSAP ScrollTrigger with Lenis smooth scroll
  if (window.lenis) {
    window.lenis.on('scroll', ScrollTrigger.update);
  }

  // Scroll-reveal for .reveal-up, .reveal-left, .reveal-right
  const revealEls = document.querySelectorAll('.reveal-up,.reveal-left,.reveal-right');
  revealEls.forEach((el, i) => {
    ScrollTrigger.create({
      trigger: el,
      start: 'top 88%',
      onEnter: () => {
        gsap.to(el, {
          opacity: 1, y: 0, x: 0, scale: 1,
          duration: 0.75,
          delay: (i % 4) * 0.06,
          ease: 'power3.out',
          force3D: true,
          onStart: () => el.classList.add('revealed'),
        });
      },
      once: true,
    });
  });

  // Stagger feat-cards within grid
  document.querySelectorAll('.feat-grid').forEach(grid => {
    const cards = grid.querySelectorAll('.feat-card');
    ScrollTrigger.create({
      trigger: grid,
      start: 'top 85%',
      onEnter: () => {
        gsap.fromTo(cards,
          { opacity: 0, y: 35, scale: 0.97 },
          { opacity: 1, y: 0, scale: 1, duration: 0.68, stagger: 0.06, ease: 'power3.out', force3D: true }
        );
      },
      once: true,
    });
  });

  // Hero elements stagger after zoom animation settles
  setTimeout(() => {
    const heroEls = document.querySelectorAll('.hero-status-pill,.hero-title-sub,.motto-strip,.hero-sub,.hero-actions,.hero-metrics-bar,.hero-offline-notice,.hero-mockup');
    gsap.fromTo(heroEls,
      { opacity: 0, y: 18 },
      { opacity: 1, y: 0, duration: 0.65, stagger: 0.08, ease: 'power3.out', force3D: true }
    );
  }, 450);
}

/* ═══════════════════════════════════════════════════════════════════
   5. NAVIGATION — scroll-shrink + active link
═══════════════════════════════════════════════════════════════════ */
function initNav() {
  const nav = document.getElementById('nav');
  if (!nav) return;

  // Scroll-shrink effect
  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 60);
  }, { passive: true });

  // Active nav link highlighting
  const sections = document.querySelectorAll('section[id], div[id]');
  const navLinks  = document.querySelectorAll('.nav-links a');

  const obs = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) {
        const id = e.target.id;
        navLinks.forEach(a => {
          const href = a.getAttribute('href');
          a.style.color = href === `#${id}` ? 'var(--coral)' : '';
          a.style.background = href === `#${id}` ? 'rgba(255,82,43,0.15)' : '';
        });
      }
    });
  }, { threshold: 0.35 });

  sections.forEach(s => obs.observe(s));
}

/* ── Mobile nav toggle ─────────────────────────────────────────── */
function initNavToggle() {
  const toggle = document.getElementById('navToggle');
  const links  = document.getElementById('navLinks');
  if (!toggle || !links) return;

  toggle.addEventListener('click', () => {
    const open = links.classList.toggle('open');
    toggle.setAttribute('aria-expanded', open);
    // Animate hamburger → X
    const spans = toggle.querySelectorAll('span');
    if (open) {
      spans[0].style.transform = 'rotate(45deg) translate(5px,5px)';
      spans[1].style.opacity   = '0';
      spans[2].style.transform = 'rotate(-45deg) translate(5px,-5px)';
    } else {
      spans.forEach(s => { s.style.transform = ''; s.style.opacity = ''; });
    }
  });

  // Close on link click
  links.querySelectorAll('a').forEach(a => {
    a.addEventListener('click', () => {
      links.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
      toggle.querySelectorAll('span').forEach(s => { s.style.transform = ''; s.style.opacity = ''; });
    });
  });

  // Close on outside click
  document.addEventListener('click', (e) => {
    if (!toggle.contains(e.target) && !links.contains(e.target)) {
      links.classList.remove('open');
    }
  });
}

/* ═══════════════════════════════════════════════════════════════════
   6. GITHUB STARS
═══════════════════════════════════════════════════════════════════ */
function initGitHubStars() {
  const el = document.getElementById('starCount');
  if (!el) return;
  fetch('https://api.github.com/repos/Naveen-21-Cyber/Pariyojana-Mobile-App-', {
    headers: { 'Accept': 'application/vnd.github.v3+json' }
  })
    .then(r => r.json())
    .then(d => {
      if (d.stargazers_count !== undefined) {
        el.textContent = `⭐ ${d.stargazers_count}`;
      }
    })
    .catch(() => { el.textContent = '⭐ Star'; });
}

/* ═══════════════════════════════════════════════════════════════════
   7. SIM TAB SWITCHER
═══════════════════════════════════════════════════════════════════ */
function simTab(id) {
  document.querySelectorAll('.sv').forEach(v => v.classList.remove('sv--on'));
  document.querySelectorAll('.stab').forEach(b => b.classList.remove('stab--on'));
  const view = document.getElementById('v-' + id);
  const btn  = document.getElementById('t-' + id);
  if (view) view.classList.add('sv--on');
  if (btn)  btn.classList.add('stab--on');
}

/* ═══════════════════════════════════════════════════════════════════
   8. FOCUS TIMER DEMO
═══════════════════════════════════════════════════════════════════ */
function initTimerDemo() {
  updateTimerDisplay();
  updateShloka();
}

function setDur(mins) {
  if (timerRunning) return;
  timerTotal = mins * 60;
  timerLeft  = timerTotal;
  document.querySelectorAll('.dur').forEach(b => {
    b.classList.toggle('dur--on', b.textContent.trim() === mins + 'm');
  });
  updateTimerDisplay();
}

function toggleTimer() {
  if (timerRunning) { pauseTimer(); } else { startTimer(); }
}

function startTimer() {
  timerRunning = true;
  document.getElementById('playBtn').textContent = '⏸';
  timerInterval = setInterval(() => {
    if (timerLeft > 0) {
      timerLeft--;
      updateTimerDisplay();
    } else {
      clearInterval(timerInterval);
      timerRunning = false;
      document.getElementById('playBtn').textContent = '▶';
      nextShloka();
    }
  }, 1000);
}

function pauseTimer() {
  clearInterval(timerInterval);
  timerRunning = false;
  document.getElementById('playBtn').textContent = '▶';
}

function resetTimer() {
  clearInterval(timerInterval);
  timerRunning = false;
  timerLeft = timerTotal;
  document.getElementById('playBtn').textContent = '▶';
  updateTimerDisplay();
}

function updateTimerDisplay() {
  const m = String(Math.floor(timerLeft / 60)).padStart(2,'0');
  const s = String(timerLeft % 60).padStart(2,'0');
  const el = document.getElementById('timerTime');
  if (el) el.textContent = `${m}:${s}`;

  // Update SVG ring
  const fill = document.getElementById('trFill');
  if (fill) {
    const pct = timerLeft / timerTotal;
    fill.style.strokeDashoffset = 314.16 * (1 - pct);
  }
}

function nextShloka() {
  shlokaIdx = (shlokaIdx + 1) % SHLOKAS.length;
  updateShloka();
}

function updateShloka() {
  const s = SHLOKAS[shlokaIdx];
  const sEl = document.getElementById('svSanskrit');
  const eEl = document.getElementById('svTrans');
  if (sEl) sEl.textContent = s.s;
  if (eEl) eEl.textContent = s.e;
}

/* ═══════════════════════════════════════════════════════════════════
   9. BYOK TOKEN CALC DEMO
═══════════════════════════════════════════════════════════════════ */
function calcTokens() {
  const text = document.getElementById('byokInput')?.value || '';
  const orig = Math.ceil(text.length / 4); // rough token estimate
  const saved_pct = 0.62;
  const compressed = Math.ceil(orig * (1 - saved_pct));
  const saved = orig - compressed;

  const fmt = n => n.toLocaleString() + ' tokens';
  const origEl = document.getElementById('bOrig');
  const compEl = document.getElementById('bComp');
  const savedEl= document.getElementById('bSaved');

  if (origEl)  origEl.textContent  = fmt(orig);
  if (compEl)  compEl.textContent  = fmt(compressed);
  if (savedEl) savedEl.textContent = fmt(saved) + ` (${Math.round(saved_pct * 100)}% saved)`;
}

/* ═══════════════════════════════════════════════════════════════════
   10. CONTACT FORM CSRF GUARD
═══════════════════════════════════════════════════════════════════ */
document.addEventListener('DOMContentLoaded', () => {
  const tok = document.getElementById('csrfTokenVal');
  if (tok) {
    const arr = new Uint8Array(16);
    crypto.getRandomValues(arr);
    tok.value = Array.from(arr, b => b.toString(16).padStart(2,'0')).join('');
  }

  // Auto-close success message banner
  const params = new URLSearchParams(window.location.search);
  if (params.get('msg') === 'sent') {
    const banner = document.createElement('div');
    banner.style.cssText = `
      position:fixed;bottom:24px;left:50%;transform:translateX(-50%);
      background:#10B981;color:#fff;padding:14px 28px;border-radius:50px;
      font-weight:700;font-size:0.9rem;z-index:9998;
      box-shadow:0 8px 30px rgba(16,185,129,0.5);
    `;
    banner.textContent = '✅ Message sent successfully! Naveen will respond soon.';
    document.body.appendChild(banner);
    setTimeout(() => banner.remove(), 5000);
  }
});

