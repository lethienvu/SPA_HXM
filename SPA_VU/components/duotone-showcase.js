/**
 * PARADISE HR - DUOTONE ICON SHOWCASE
 * Demo component để test toàn bộ duotone icon system
 */

const DuotoneIconShowcase = {
  template: `
    <div class="duotone-showcase">
      <div class="container py-5">
        <!-- Header -->
        <div class="text-center mb-5">
          <h1 class="display-4 text-paradise-primary mb-3">
            <span data-icon="paradisehr_main" data-icon-size="xl" class="me-3"></span>
            Paradise HR Duotone Icons
          </h1>
          <p class="lead text-muted">Professional duotone icon system với 250+ icons</p>
          <div class="badge bg-success me-2">250 Icons</div>
          <div class="badge bg-primary me-2">Duotone Style</div>
          <div class="badge bg-info">Paradise HR Branded</div>
        </div>

        <!-- Quick Stats -->
        <div class="row mb-5">
          <div class="col-md-3 text-center">
            <div class="stat-card p-4 bg-light rounded-3">
              <span data-icon="chart-pie-simple" data-icon-size="2xl" data-icon-color="primary" class="d-block mb-3"></span>
              <h3 class="h4">250+</h3>
              <p class="text-muted mb-0">Total Icons</p>
            </div>
          </div>
          <div class="col-md-3 text-center">
            <div class="stat-card p-4 bg-light rounded-3">
              <span data-icon="color-swatch" data-icon-size="2xl" data-icon-color="success" class="d-block mb-3"></span>
              <h3 class="h4">Duotone</h3>
              <p class="text-muted mb-0">Style System</p>
            </div>
          </div>
          <div class="col-md-3 text-center">
            <div class="stat-card p-4 bg-light rounded-3">
              <span data-icon="design-1" data-icon-size="2xl" data-icon-color="info" class="d-block mb-3"></span>
              <h3 class="h4">Paradise</h3>
              <p class="text-muted mb-0">HR Branded</p>
            </div>
          </div>
          <div class="col-md-3 text-center">
            <div class="stat-card p-4 bg-light rounded-3">
              <span data-icon="rocket" data-icon-size="2xl" data-icon-color="warning" class="d-block mb-3"></span>
              <h3 class="h4">Auto</h3>
              <p class="text-muted mb-0">Initialization</p>
            </div>
          </div>
        </div>

        <!-- Icon Categories -->
        <div class="icon-categories">
          
          <!-- Paradise HR Business Icons -->
          <div class="category-section mb-5">
            <h2 class="h3 mb-4 text-paradise-primary">
              <span data-icon="hrm" data-icon-size="lg" class="me-2"></span>
              Paradise HR Business Icons
            </h2>
            <div class="icon-grid">
              <div class="icon-item" data-icon="paradisehr_main">
                <div class="icon-display">
                  <span data-icon="paradisehr_main" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">paradisehr_main</div>
              </div>
              <div class="icon-item" data-icon="hrm">
                <div class="icon-display">
                  <span data-icon="hrm" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">hrm</div>
              </div>
              <div class="icon-item" data-icon="paudit">
                <div class="icon-display">
                  <span data-icon="paudit" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">paudit</div>
              </div>
              <div class="icon-item" data-icon="pevaluation">
                <div class="icon-display">
                  <span data-icon="pevaluation" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">pevaluation</div>
              </div>
              <div class="icon-item" data-icon="pmeal">
                <div class="icon-display">
                  <span data-icon="pmeal" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">pmeal</div>
              </div>
              <div class="icon-item" data-icon="ptraining">
                <div class="icon-display">
                  <span data-icon="ptraining" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">ptraining</div>
              </div>
              <div class="icon-item" data-icon="phiring">
                <div class="icon-display">
                  <span data-icon="phiring" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">phiring</div>
              </div>
              <div class="icon-item" data-icon="paradiseportal">
                <div class="icon-display">
                  <span data-icon="paradiseportal" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">paradiseportal</div>
              </div>
            </div>
          </div>

          <!-- Navigation & Interface -->
          <div class="category-section mb-5">
            <h2 class="h3 mb-4 text-paradise-secondary">
              <span data-icon="menu" data-icon-size="lg" class="me-2"></span>
              Navigation & Interface
            </h2>
            <div class="icon-grid">
              <div class="icon-item" data-icon="home">
                <div class="icon-display">
                  <span data-icon="home" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">home</div>
              </div>
              <div class="icon-item" data-icon="menu">
                <div class="icon-display">
                  <span data-icon="menu" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">menu</div>
              </div>
              <div class="icon-item" data-icon="settings">
                <div class="icon-display">
                  <span data-icon="settings" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">settings</div>
              </div>
              <div class="icon-item" data-icon="search">
                <div class="icon-display">
                  <span data-icon="search" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">search</div>
              </div>
              <div class="icon-item" data-icon="filter">
                <div class="icon-display">
                  <span data-icon="filter" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">filter</div>
              </div>
              <div class="icon-item" data-icon="sort">
                <div class="icon-display">
                  <span data-icon="sort" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">sort</div>
              </div>
            </div>
          </div>

          <!-- User & People -->
          <div class="category-section mb-5">
            <h2 class="h3 mb-4 text-paradise-primary">
              <span data-icon="people" data-icon-size="lg" class="me-2"></span>
              User & People
            </h2>
            <div class="icon-grid">
              <div class="icon-item" data-icon="user">
                <div class="icon-display">
                  <span data-icon="user" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">user</div>
              </div>
              <div class="icon-item" data-icon="people">
                <div class="icon-display">
                  <span data-icon="people" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">people</div>
              </div>
              <div class="icon-item" data-icon="profile-circle">
                <div class="icon-display">
                  <span data-icon="profile-circle" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">profile-circle</div>
              </div>
              <div class="icon-item" data-icon="user-edit">
                <div class="icon-display">
                  <span data-icon="user-edit" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">user-edit</div>
              </div>
              <div class="icon-item" data-icon="user-tick">
                <div class="icon-display">
                  <span data-icon="user-tick" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">user-tick</div>
              </div>
              <div class="icon-item" data-icon="profile-2user">
                <div class="icon-display">
                  <span data-icon="profile-2user" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">profile-2user</div>
              </div>
            </div>
          </div>

          <!-- Charts & Analytics -->
          <div class="category-section mb-5">
            <h2 class="h3 mb-4 text-paradise-secondary">
              <span data-icon="chart" data-icon-size="lg" class="me-2"></span>
              Charts & Analytics
            </h2>
            <div class="icon-grid">
              <div class="icon-item" data-icon="chart">
                <div class="icon-display">
                  <span data-icon="chart" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">chart</div>
              </div>
              <div class="icon-item" data-icon="chart-line-up">
                <div class="icon-display">
                  <span data-icon="chart-line-up" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">chart-line-up</div>
              </div>
              <div class="icon-item" data-icon="chart-pie-simple">
                <div class="icon-display">
                  <span data-icon="chart-pie-simple" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">chart-pie-simple</div>
              </div>
              <div class="icon-item" data-icon="graph">
                <div class="icon-display">
                  <span data-icon="graph" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">graph</div>
              </div>
              <div class="icon-item" data-icon="ranking">
                <div class="icon-display">
                  <span data-icon="ranking" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">ranking</div>
              </div>
              <div class="icon-item" data-icon="graph-up">
                <div class="icon-display">
                  <span data-icon="graph-up" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">graph-up</div>
              </div>
            </div>
          </div>

          <!-- Technology & Devices -->
          <div class="category-section mb-5">
            <h2 class="h3 mb-4 text-info">
              <span data-icon="laptop" data-icon-size="lg" class="me-2"></span>
              Technology & Devices
            </h2>
            <div class="icon-grid">
              <div class="icon-item" data-icon="laptop">
                <div class="icon-display">
                  <span data-icon="laptop" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">laptop</div>
              </div>
              <div class="icon-item" data-icon="phone">
                <div class="icon-display">
                  <span data-icon="phone" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">phone</div>
              </div>
              <div class="icon-item" data-icon="tablet">
                <div class="icon-display">
                  <span data-icon="tablet" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">tablet</div>
              </div>
              <div class="icon-item" data-icon="wi-fi">
                <div class="icon-display">
                  <span data-icon="wi-fi" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">wi-fi</div>
              </div>
              <div class="icon-item" data-icon="bluetooth">
                <div class="icon-display">
                  <span data-icon="bluetooth" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">bluetooth</div>
              </div>
              <div class="icon-item" data-icon="network">
                <div class="icon-display">
                  <span data-icon="network" data-icon-size="2xl" data-icon-interactive></span>
                </div>
                <div class="icon-name">network</div>
              </div>
            </div>
          </div>

        </div>

        <!-- Icon Showcase Controls -->
        <div class="showcase-controls mt-5 p-4 bg-light rounded-3">
          <h3 class="h5 mb-3">Icon Showcase Controls</h3>
          <div class="row">
            <div class="col-md-4">
              <label class="form-label">Icon Size</label>
              <select class="form-select" id="iconSizeSelect">
                <option value="xs">Extra Small (xs)</option>
                <option value="sm">Small (sm)</option>
                <option value="md">Medium (md)</option>
                <option value="lg">Large (lg)</option>
                <option value="xl">Extra Large (xl)</option>
                <option value="2xl" selected>2X Large (2xl)</option>
                <option value="3xl">3X Large (3xl)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Color Theme</label>
              <select class="form-select" id="colorThemeSelect">
                <option value="">Default</option>
                <option value="primary">Primary</option>
                <option value="secondary">Secondary</option>
                <option value="success">Success</option>
                <option value="warning">Warning</option>
                <option value="danger">Danger</option>
                <option value="info">Info</option>
                <option value="muted">Muted</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Animation</label>
              <select class="form-select" id="animationSelect">
                <option value="">No Animation</option>
                <option value="spin">Spin</option>
                <option value="pulse">Pulse</option>
                <option value="bounce">Bounce</option>
              </select>
            </div>
          </div>
          <div class="mt-3">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" id="interactiveCheck" checked>
              <label class="form-check-label" for="interactiveCheck">
                Interactive Hover Effects
              </label>
            </div>
          </div>
        </div>

        <!-- Usage Examples -->
        <div class="usage-examples mt-5">
          <h2 class="h3 mb-4">Usage Examples</h2>
          
          <div class="row">
            <div class="col-md-6">
              <div class="example-card p-4 border rounded-3">
                <h4 class="h5 mb-3">Data Attributes (Recommended)</h4>
                <pre class="bg-light p-3 rounded"><code>&lt;span data-icon="home" data-icon-size="lg"&gt;&lt;/span&gt;
&lt;span data-icon="user" data-icon-color="primary"&gt;&lt;/span&gt;
&lt;span data-icon="settings" data-icon-interactive&gt;&lt;/span&gt;</code></pre>
              </div>
            </div>
            
            <div class="col-md-6">
              <div class="example-card p-4 border rounded-3">
                <h4 class="h5 mb-3">JavaScript API</h4>
                <pre class="bg-light p-3 rounded"><code>// Create icon
ParadiseIcons.createIcon('home', { size: 'lg' })

// Create with container
ParadiseIcons.createIconWithContainer('user')

// Create with badge
ParadiseIcons.createIconWithBadge('notification', 5)</code></pre>
              </div>
            </div>
          </div>
        </div>

      </div>
    </div>
  `,

  mounted() {
    this.initializeControls();
  },

  methods: {
    initializeControls() {
      // Size control
      document
        .getElementById("iconSizeSelect")
        ?.addEventListener("change", (e) => {
          const size = e.target.value;
          document
            .querySelectorAll(".icon-display span[data-icon]")
            .forEach((icon) => {
              icon.setAttribute("data-icon-size", size);
            });
          // Re-process icons
          if (window.ParadiseIcons) {
            window.ParadiseIcons.refresh();
          }
        });

      // Color control
      document
        .getElementById("colorThemeSelect")
        ?.addEventListener("change", (e) => {
          const color = e.target.value;
          document
            .querySelectorAll(".icon-display span[data-icon]")
            .forEach((icon) => {
              if (color) {
                icon.setAttribute("data-icon-color", color);
              } else {
                icon.removeAttribute("data-icon-color");
              }
            });
          // Re-process icons
          if (window.ParadiseIcons) {
            window.ParadiseIcons.refresh();
          }
        });

      // Animation control
      document
        .getElementById("animationSelect")
        ?.addEventListener("change", (e) => {
          const animation = e.target.value;
          document
            .querySelectorAll(".icon-display span[data-icon]")
            .forEach((icon) => {
              if (animation) {
                icon.setAttribute("data-icon-animation", animation);
              } else {
                icon.removeAttribute("data-icon-animation");
              }
            });
          // Re-process icons
          if (window.ParadiseIcons) {
            window.ParadiseIcons.refresh();
          }
        });

      // Interactive control
      document
        .getElementById("interactiveCheck")
        ?.addEventListener("change", (e) => {
          const interactive = e.target.checked;
          document
            .querySelectorAll(".icon-display span[data-icon]")
            .forEach((icon) => {
              if (interactive) {
                icon.setAttribute("data-icon-interactive", "");
              } else {
                icon.removeAttribute("data-icon-interactive");
              }
            });
          // Re-process icons
          if (window.ParadiseIcons) {
            window.ParadiseIcons.refresh();
          }
        });
    },
  },
};

// CSS cho showcase
const showcaseStyles = `
<style>
.duotone-showcase {
  background: linear-gradient(135deg, #f8fffe 0%, #f0fef7 100%);
  min-height: 100vh;
}

.text-paradise-primary {
  color: var(--paradise-primary, #73c41d) !important;
}

.text-paradise-secondary {
  color: var(--paradise-secondary, #004c39) !important;
}

.stat-card {
  transition: transform 0.2s ease;
}

.stat-card:hover {
  transform: translateY(-2px);
}

.icon-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(150px, 1fr));
  gap: 1rem;
}

.icon-item {
  text-align: center;
  padding: 1rem;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  background: white;
  transition: all 0.2s ease;
}

.icon-item:hover {
  border-color: var(--paradise-primary, #73c41d);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(115, 196, 29, 0.1);
}

.icon-display {
  margin-bottom: 0.5rem;
  min-height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.icon-name {
  font-size: 0.875rem;
  color: #6b7280;
  font-family: 'Courier New', monospace;
  word-break: break-all;
}

.category-section {
  margin-bottom: 3rem;
}

.example-card {
  height: 100%;
}

.example-card code {
  font-size: 0.875rem;
  color: #374151;
}

@media (max-width: 768px) {
  .icon-grid {
    grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
    gap: 0.75rem;
  }
  
  .icon-item {
    padding: 0.75rem;
  }
}
</style>
`;

// Inject styles
document.head.insertAdjacentHTML("beforeend", showcaseStyles);

export default DuotoneIconShowcase;
