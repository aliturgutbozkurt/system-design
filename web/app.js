/* ==============================================================================
   MAANG SYSTEM DESIGN ELI5 - JAVASCRIPT APP CONTROLLER
   Offline-first (file:// and http:// compatible), Instant Search, Multi-language
   ============================================================================== */

let appData = null;
let currentLessonNum = 1;
let currentLanguage = 'split'; // 'split', 'tr', 'en'
let allLessonsFlat = [];

document.addEventListener('DOMContentLoaded', async () => {
  await initData();
  initUI();
  handleRouting();
});

// Load curriculum data from window.LESSONS_DATA or fetch fallback
async function initData() {
  if (window.LESSONS_DATA && window.LESSONS_DATA.modules) {
    appData = window.LESSONS_DATA;
  } else {
    try {
      const response = await fetch('data/lessons.json');
      appData = await response.json();
    } catch (e) {
      console.error("Could not fetch data via fetch API, relying on window.LESSONS_DATA:", e);
    }
  }

  if (!appData || !appData.modules) {
    alert("Hata: Ders verileri yüklenemedi. Lütfen 'lessons.js' dosyasının var olduğundan emin olun.");
    return;
  }

  // Flatten lessons for quick lookup
  allLessonsFlat = [];
  appData.modules.forEach(m => {
    m.lessons.forEach(l => {
      allLessonsFlat.push({ ...l, module: m });
    });
  });
}

function initUI() {
  renderSidebar(appData.modules);
  setupLanguageSwitcher();
  setupSearch();
  setupPdfModal();
  window.addEventListener('hashchange', handleRouting);
}

// Router based on hash (#lesson-12)
function handleRouting() {
  const hash = window.location.hash;
  let targetLesson = 1;
  if (hash.startsWith('#lesson-')) {
    const num = parseInt(hash.replace('#lesson-', ''), 10);
    if (!isNaN(num) && num >= 1 && num <= 60) {
      targetLesson = num;
    }
  }
  selectLesson(targetLesson);
}

// Render Sidebar Accordion
function renderSidebar(modules) {
  const container = document.getElementById('moduleAccordion');
  container.innerHTML = '';

  modules.forEach(m => {
    const li = document.createElement('li');
    li.className = 'module-group expanded';
    li.id = `mod-group-${m.id}`;

    let lessonItemsHtml = '';
    m.lessons.forEach(l => {
      lessonItemsHtml += `
        <li>
          <button class="lesson-item-btn" id="lesson-btn-${l.num}" onclick="navigateToLesson(${l.num})">
            <span class="lesson-badge">#${l.num}</span>
            <span class="lesson-item-title">${escapeHtml(l.title_tr)}</span>
          </button>
        </li>
      `;
    });

    li.innerHTML = `
      <button class="module-header-btn" onclick="toggleModule(${m.id})">
        <div class="module-info">
          <span class="module-tag">BÖLÜM ${m.id}</span>
          <span class="module-name">${escapeHtml(m.title_tr)}</span>
        </div>
        <span class="module-arrow">▶</span>
      </button>
      <ul class="lesson-sublist">
        ${lessonItemsHtml}
      </ul>
    `;
    container.appendChild(li);
  });
}

function toggleModule(modId) {
  const group = document.getElementById(`mod-group-${modId}`);
  if (group) {
    group.classList.toggle('expanded');
  }
}

function navigateToLesson(num) {
  window.location.hash = `#lesson-${num}`;
}

// Select and Render Lesson
function selectLesson(num) {
  currentLessonNum = num;
  const item = allLessonsFlat.find(x => x.num === num);
  if (!item) return;

  // Update Sidebar active state
  document.querySelectorAll('.lesson-item-btn').forEach(btn => btn.classList.remove('active'));
  const activeBtn = document.getElementById(`lesson-btn-${num}`);
  if (activeBtn) {
    activeBtn.classList.add('active');
    // Ensure parent module is expanded
    const parentGroup = activeBtn.closest('.module-group');
    if (parentGroup && !parentGroup.classList.contains('expanded')) {
      parentGroup.classList.add('expanded');
    }
    // Scroll sidebar item into view
    activeBtn.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
  }

  // Update Lesson counter badge
  const counterBadge = document.getElementById('lessonCounterBadge');
  if (counterBadge) counterBadge.innerText = `Ders ${num} / 60`;

  // Render Lesson Content
  renderLessonView(item);
  document.getElementById('mainContent').scrollTop = 0;
}

function renderLessonView(item) {
  const main = document.getElementById('mainContent');
  const m = item.module;

  // Takeaways rendering
  let takeawaysHtml = '';
  if (item.takeaways && item.takeaways.length > 0) {
    takeawaysHtml = item.takeaways.map(t => {
      return `
        <li class="takeaway-item">
          <div><strong style="color:#10b981;">•</strong> ${escapeHtml(t[0])}</div>
          <div style="color:var(--text-secondary);"><strong style="color:#34d399;">•</strong> ${escapeHtml(t[1])}</div>
        </li>
      `;
    }).join('');
  }

  // Previous & Next navigation logic
  const prevNum = item.num > 1 ? item.num - 1 : null;
  const nextNum = item.num < 60 ? item.num + 1 : null;

  main.innerHTML = `
    <!-- Header -->
    <header class="lesson-card-header">
      <div class="lesson-meta-bar">
        <span class="module-badge-tag">BÖLÜM ${m.id}: ${escapeHtml(m.title_tr)}</span>
        <span class="lesson-number-pill">Ders #${item.num} / 60</span>
      </div>
      <h1 class="lesson-h1-tr">${escapeHtml(item.title_tr)}</h1>
      <h2 class="lesson-h2-en">${escapeHtml(item.title_en)}</h2>
    </header>

    <!-- Architectural ASCII Diagram -->
    <section class="content-section section-diagram">
      <div class="section-title-bar">
        <span class="section-label" style="color: var(--accent-cyan);">
          📐 Sistem Mimarisi & Veri Akış Şeması
        </span>
        <button class="btn-secondary" onclick="copyText('diagram-code-${item.num}')">Şemayı Kopyala</button>
      </div>
      <div class="code-container">
        <pre class="diagram-pre" id="diagram-code-${item.num}">${escapeHtml(item.diagram)}</pre>
      </div>
    </section>

    <!-- ELI5 Box -->
    <section class="content-section section-eli5">
      <div class="section-title-bar">
        <span class="section-label">
          💡 Aptala Anlatım (ELI5 Metaforu)
        </span>
      </div>
      ${renderBilingualText(item.eli5_tr, item.eli5_en)}
    </section>

    <!-- MAANG Technical Deep Dive -->
    <section class="content-section section-deep">
      <div class="section-title-bar">
        <span class="section-label">
          🔍 MAANG Seviyesi Teknik Derinlik
        </span>
      </div>
      ${renderBilingualText(item.deep_tr, item.deep_en)}
    </section>

    <!-- Java 25 Code Implementation -->
    <section class="content-section section-java">
      <div class="section-title-bar">
        <span class="section-label">
          ⚡ Modern Java 25 Uygulaması (Virtual Threads & Records)
        </span>
        <button class="btn-secondary" onclick="copyText('java-code-${item.num}')">Kodu Kopyala</button>
      </div>
      <div class="code-container">
        <button class="copy-btn" onclick="copyText('java-code-${item.num}')">Kopyala</button>
        <pre class="code-pre" id="java-code-${item.num}"><code>${escapeHtml(item.java_code)}</code></pre>
      </div>
    </section>

    <!-- Warning / Interview Bottlenecks -->
    <section class="content-section section-warning">
      <div class="section-title-bar">
        <span class="section-label">
          ⚠️ Mülakat Tuzağı & Darboğaz Uyarısı
        </span>
      </div>
      ${renderBilingualText(item.warning_tr, item.warning_en)}
    </section>

    <!-- Key Takeaways -->
    <section class="content-section section-takeaways">
      <div class="section-title-bar">
        <span class="section-label">
          🎯 Mülakatta Hatırlanacak Altın Çıkarımlar
        </span>
      </div>
      <ul class="takeaway-list">
        ${takeawaysHtml}
      </ul>
    </section>

    <!-- Bottom Navigation -->
    <footer class="bottom-nav-bar">
      <div>
        ${prevNum ? `
          <button class="btn-secondary" onclick="navigateToLesson(${prevNum})">
            ◀ Önceki Ders (#${prevNum})
          </button>
        ` : `<span></span>`}
      </div>
      <a href="../output/individual/lesson_${String(item.num).padStart(2, '0')}.pdf" target="_blank" class="btn-primary">
        📄 Bu Dersi PDF İndir (#${item.num})
      </a>
      <div>
        ${nextNum ? `
          <button class="btn-primary" onclick="navigateToLesson(${nextNum})">
            Sonraki Ders (#${nextNum}) ▶
          </button>
        ` : `<span></span>`}
      </div>
    </footer>
  `;
}

function renderBilingualText(trText, enText) {
  if (currentLanguage === 'tr') {
    return `<div class="col-tr">${escapeHtml(trText)}</div>`;
  }
  if (currentLanguage === 'en') {
    return `<div class="col-en">${escapeHtml(enText)}</div>`;
  }
  // Split mode (both side by side)
  return `
    <div class="dual-grid">
      <div class="col-tr">
        <div class="col-badge col-badge-tr">🇹🇷 TÜRKÇE</div>
        ${escapeHtml(trText)}
      </div>
      <div class="col-en">
        <div class="col-badge col-badge-en">🇬🇧 ENGLISH</div>
        ${escapeHtml(enText)}
      </div>
    </div>
  `;
}

// Language Switcher Handlers
function setupLanguageSwitcher() {
  const buttons = document.querySelectorAll('.lang-btn');
  buttons.forEach(btn => {
    btn.addEventListener('click', () => {
      buttons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      currentLanguage = btn.getAttribute('data-lang');
      const item = allLessonsFlat.find(x => x.num === currentLessonNum);
      if (item) renderLessonView(item);
    });
  });
}

// Search Filtering across all 60 lessons
function setupSearch() {
  const searchInput = document.getElementById('searchInput');
  if (!searchInput) return;

  searchInput.addEventListener('input', (e) => {
    const q = e.target.value.trim().toLowerCase();
    if (!q) {
      renderSidebar(appData.modules);
      selectLesson(currentLessonNum);
      return;
    }

    // Filter modules and lessons
    const filteredModules = [];
    appData.modules.forEach(m => {
      const matchedLessons = m.lessons.filter(l => {
        return (
          l.num.toString() === q ||
          l.title_tr.toLowerCase().includes(q) ||
          l.title_en.toLowerCase().includes(q) ||
          l.eli5_tr.toLowerCase().includes(q) ||
          l.eli5_en.toLowerCase().includes(q) ||
          l.deep_tr.toLowerCase().includes(q) ||
          l.deep_en.toLowerCase().includes(q) ||
          l.java_code.toLowerCase().includes(q)
        );
      });

      if (matchedLessons.length > 0) {
        filteredModules.push({ ...m, lessons: matchedLessons });
      }
    });

    renderSidebar(filteredModules);
  });
}

// Setup PDF Library Modal
function setupPdfModal() {
  const modal = document.getElementById('pdfModal');
  const btnOpen = document.getElementById('btnOpenPdfModal');
  const btnClose = document.getElementById('btnClosePdfModal');

  if (btnOpen) btnOpen.addEventListener('click', () => modal.classList.add('open'));
  if (btnClose) btnClose.addEventListener('click', () => modal.classList.remove('open'));
  modal.addEventListener('click', (e) => {
    if (e.target === modal) modal.classList.remove('open');
  });

  // Populate 10 Module Bundles
  const moduleListContainer = document.getElementById('modalModulePdfList');
  if (moduleListContainer && appData && appData.modules) {
    moduleListContainer.innerHTML = appData.modules.map(m => {
      const pdfFileName = `module_${String(m.id).padStart(2, '0')}_${m.dir}.pdf`;
      return `
        <div class="pdf-item">
          <div>
            <div style="font-weight: 700; color: white;">📦 Bölüm ${m.id}: ${escapeHtml(m.title_tr)}</div>
            <div style="font-size: 0.78rem; color: var(--text-secondary);">${escapeHtml(m.title_en)} (6 Ders)</div>
          </div>
          <a href="../output/modules/${pdfFileName}" target="_blank" class="btn-secondary" style="padding: 4px 10px; font-size: 0.8rem;">
            ⬇️ İndir (PDF)
          </a>
        </div>
      `;
    }).join('');
  }

  // Populate 60 Individual Lessons
  const individualListContainer = document.getElementById('modalIndividualPdfList');
  if (individualListContainer && allLessonsFlat.length > 0) {
    individualListContainer.innerHTML = allLessonsFlat.map(l => {
      const pdfFileName = `lesson_${String(l.num).padStart(2, '0')}.pdf`;
      return `
        <a href="../output/individual/${pdfFileName}" target="_blank" class="pdf-pill-link">
          <span><strong>#${l.num}</strong> ${escapeHtml(l.title_tr.substring(0, 26))}...</span>
          <span style="color: var(--accent-cyan);">PDF ⬇</span>
        </a>
      `;
    }).join('');
  }
}

// Copy to Clipboard Utility
function copyText(elementId) {
  const el = document.getElementById(elementId);
  if (!el) return;
  const text = el.innerText;
  navigator.clipboard.writeText(text).then(() => {
    showToast("Panoya Kopyalandı!");
  }).catch(() => {
    showToast("Kopyalama başarısız oldu.");
  });
}

function showToast(msg) {
  const toast = document.getElementById('toastNotification');
  if (!toast) return;
  toast.innerText = msg;
  toast.classList.remove('toast-hidden');
  setTimeout(() => {
    toast.classList.add('toast-hidden');
  }, 2000);
}

function escapeHtml(str) {
  if (!str) return '';
  return str
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#039;");
}
