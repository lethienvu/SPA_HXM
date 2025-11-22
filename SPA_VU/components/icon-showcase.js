/**
 * PARADISE HR - ICON SHOWCASE PAGE
 * Trang demo hệ thống Paradise Icons
 */

class IconShowcasePage extends Component {
  constructor() {
    super("icon-showcase");
  }

  async render() {
    return `
            <div class="icon-showcase-page">
                <!-- Page Header -->
                <div class="page-header">
                    <h1 class="page-title">Paradise Icon System</h1>
                    <p class="page-description">
                        Hệ thống icon SVG sprite tùy chỉnh với màu sắc thương hiệu Paradise HR.
                        Tất cả icons được tối ưu hóa cho hiệu suất và nhất quán về phong cách.
                    </p>
                </div>

                <!-- Color Palette -->
                <section class="icon-section">
                    <h2 class="section-title">Bảng Màu Thương Hiệu</h2>
                    <div class="color-palette">
                        <div class="color-item">
                            <div class="color-swatch" style="background: linear-gradient(135deg, #73c41d 0%, #71c11d 100%);"></div>
                            <div class="color-info">
                                <div class="color-name">Paradise Gradient</div>
                                <div class="color-value">#73c41d → #71c11d</div>
                            </div>
                        </div>
                        <div class="color-item">
                            <div class="color-swatch" style="background: linear-gradient(135deg, #004c39 0%, #004b38 100%);"></div>
                            <div class="color-info">
                                <div class="color-name">Dark Gradient</div>
                                <div class="color-value">#004c39 → #004b38</div>
                            </div>
                        </div>
                        <div class="color-item">
                            <div class="color-swatch" style="background: #72c31d;"></div>
                            <div class="color-info">
                                <div class="color-name">Primary Green</div>
                                <div class="color-value">#72c31d</div>
                            </div>
                        </div>
                        <div class="color-item">
                            <div class="color-swatch" style="background: #004c39;"></div>
                            <div class="color-info">
                                <div class="color-name">Dark Green</div>
                                <div class="color-value">#004c39</div>
                            </div>
                        </div>
                        <div class="color-item">
                            <div class="color-swatch" style="background: #fbfcfc; border: 1px solid #e5e7eb;"></div>
                            <div class="color-info">
                                <div class="color-name">Light</div>
                                <div class="color-value">#fbfcfc</div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- All Icons Grid -->
                <section class="icon-section">
                    <h2 class="section-title">Tất Cả Icons (${
                      UI.icon.list().length
                    } icons)</h2>
                    <div class="paradise-icon-grid" id="allIconsGrid"></div>
                </section>

                <!-- Size Variations -->
                <section class="icon-section">
                    <h2 class="section-title">Kích Thước</h2>
                    <div class="size-demo">
                        ${["xs", "sm", "md", "lg", "xl", "2xl"]
                          .map(
                            (size) => `
                            <div class="size-item">
                                ${UI.icon.create("home", {
                                  size,
                                  color: "primary",
                                })}
                                <span class="size-label">${size}</span>
                            </div>
                        `
                          )
                          .join("")}
                    </div>
                </section>

                <!-- Color Variations -->
                <section class="icon-section">
                    <h2 class="section-title">Biến Thể Màu Sắc</h2>
                    <div class="color-demo">
                        ${[
                          "primary",
                          "secondary",
                          "dark",
                          "light",
                          "success",
                          "warning",
                          "danger",
                          "info",
                        ]
                          .map(
                            (color) => `
                            <div class="color-variant-item">
                                <div class="icon-container" style="background: ${
                                  color === "light" ? "#1f2937" : "#f3f4f6"
                                };">
                                    ${UI.icon.create("users", {
                                      size: "lg",
                                      color,
                                    })}
                                </div>
                                <span class="variant-label">${color}</span>
                            </div>
                        `
                          )
                          .join("")}
                    </div>
                </section>

                <!-- Containers -->
                <section class="icon-section">
                    <h2 class="section-title">Icon Containers</h2>
                    <div class="container-demo">
                        <div class="container-item">
                            ${UI.icon.withContainer("notification", {
                              containerVariant: "primary",
                              size: "md",
                            })}
                            <span class="container-label">Primary</span>
                        </div>
                        <div class="container-item">
                            ${UI.icon.withContainer("settings", {
                              containerVariant: "secondary",
                              size: "md",
                            })}
                            <span class="container-label">Secondary</span>
                        </div>
                        <div class="container-item">
                            ${UI.icon.withContainer("users", {
                              containerVariant: "glass",
                              size: "md",
                            })}
                            <span class="container-label">Glass</span>
                        </div>
                        <div class="container-item">
                            ${UI.icon.withContainer("document", {
                              containerVariant: "glass",
                              interactive: true,
                              size: "md",
                            })}
                            <span class="container-label">Interactive</span>
                        </div>
                    </div>
                </section>

                <!-- Badges -->
                <section class="icon-section">
                    <h2 class="section-title">Icon với Badges</h2>
                    <div class="badge-demo">
                        <div class="badge-item">
                            ${UI.icon.withBadge("notification", 5, {
                              size: "lg",
                              color: "primary",
                            })}
                            <span class="badge-label">Notifications</span>
                        </div>
                        <div class="badge-item">
                            ${UI.icon.withBadge("notification", 99, {
                              size: "lg",
                              color: "dark",
                            })}
                            <span class="badge-label">High Count</span>
                        </div>
                        <div class="badge-item">
                            ${UI.icon.withBadge("notification", "!", {
                              size: "lg",
                              color: "warning",
                            })}
                            <span class="badge-label">Alert</span>
                        </div>
                    </div>
                </section>

                <!-- Animations -->
                <section class="icon-section">
                    <h2 class="section-title">Animations</h2>
                    <div class="animation-demo">
                        <div class="animation-item">
                            ${UI.icon.create("loading", {
                              size: "xl",
                              color: "primary",
                              animation: "spin",
                            })}
                            <span class="animation-label">Spin</span>
                        </div>
                        <div class="animation-item">
                            ${UI.icon.create("settings", {
                              size: "xl",
                              color: "secondary",
                              animation: "rotate",
                            })}
                            <span class="animation-label">Rotate</span>
                        </div>
                        <div class="animation-item">
                            ${UI.icon.create("notification", {
                              size: "xl",
                              color: "warning",
                              animation: "pulse",
                            })}
                            <span class="animation-label">Pulse</span>
                        </div>
                    </div>
                </section>

                <!-- Interactive Demo -->
                <section class="icon-section">
                    <h2 class="section-title">Interactive Icons</h2>
                    <div class="interactive-demo">
                        ${[
                          "home",
                          "users",
                          "document",
                          "calendar",
                          "settings",
                          "notification",
                        ]
                          .map(
                            (icon) => `
                            <div class="interactive-icon-item">
                                ${UI.icon.create(icon, {
                                  size: "xl",
                                  color: "primary",
                                  interactive: true,
                                })}
                            </div>
                        `
                          )
                          .join("")}
                    </div>
                </section>

                <!-- Usage Examples -->
                <section class="icon-section">
                    <h2 class="section-title">Cách Sử Dụng</h2>
                    <div class="usage-examples">
                        <div class="usage-item">
                            <h3>1. Icon Cơ Bản</h3>
                            <pre><code>UI.icon.create('home')</code></pre>
                            <div class="usage-result">${UI.icon.create(
                              "home"
                            )}</div>
                        </div>

                        <div class="usage-item">
                            <h3>2. Icon với Options</h3>
                            <pre><code>UI.icon.create('users', { 
    size: 'lg', 
    color: 'primary',
    interactive: true
})</code></pre>
                            <div class="usage-result">${UI.icon.create(
                              "users",
                              {
                                size: "lg",
                                color: "primary",
                                interactive: true,
                              }
                            )}</div>
                        </div>

                        <div class="usage-item">
                            <h3>3. Icon với Container</h3>
                            <pre><code>UI.icon.withContainer('notification', { 
    containerVariant: 'primary',
    interactive: true
})</code></pre>
                            <div class="usage-result">${UI.icon.withContainer(
                              "notification",
                              { containerVariant: "primary", interactive: true }
                            )}</div>
                        </div>

                        <div class="usage-item">
                            <h3>4. Icon với Badge</h3>
                            <pre><code>UI.icon.withBadge('notification', 5, { 
    color: 'primary',
    size: 'lg'
})</code></pre>
                            <div class="usage-result">${UI.icon.withBadge(
                              "notification",
                              5,
                              { color: "primary", size: "lg" }
                            )}</div>
                        </div>

                        <div class="usage-item">
                            <h3>5. Tạo DOM Element</h3>
                            <pre><code>const icon = UI.icon.createElement('home', { size: 'lg' });
document.body.appendChild(icon);</code></pre>
                            <button class="btn btn-primary btn-sm" onclick="this.testCreateElement()">
                                Thử Nghiệm
                            </button>
                        </div>
                    </div>
                </section>

                <!-- Integration Examples -->
                <section class="icon-section">
                    <h2 class="section-title">Ví Dụ Tích Hợp</h2>
                    <div class="integration-examples">
                        <!-- Button with Icon -->
                        <div class="integration-item">
                            <h3>Button với Icon</h3>
                            <button class="btn btn-primary">
                                ${UI.icon.create("plus", { size: "sm" })}
                                Thêm Mới
                            </button>
                            <button class="btn btn-success">
                                ${UI.icon.create("check", { size: "sm" })}
                                Xác Nhận
                            </button>
                            <button class="btn btn-danger">
                                ${UI.icon.create("delete", { size: "sm" })}
                                Xóa
                            </button>
                        </div>

                        <!-- Input with Icon -->
                        <div class="integration-item">
                            <h3>Input với Icon</h3>
                            <div class="input-group-icon" style="position: relative; max-width: 300px;">
                                ${UI.icon.create("search", { size: "sm" })}
                                <input type="text" class="form-control" placeholder="Tìm kiếm..." style="padding-left: 40px;">
                            </div>
                        </div>

                        <!-- Card with Icons -->
                        <div class="integration-item">
                            <h3>Card với Icons</h3>
                            <div class="glass-card" style="max-width: 300px;">
                                <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
                                    ${UI.icon.withContainer("users", {
                                      containerVariant: "primary",
                                      size: "md",
                                    })}
                                    <div>
                                        <div style="font-weight: 600;">Quản Lý Nhân Viên</div>
                                        <div style="font-size: 14px; color: #6b7280;">1,234 nhân viên</div>
                                    </div>
                                </div>
                                <button class="btn btn-primary btn-sm" style="width: 100%;">
                                    ${UI.icon.create("arrow-right", {
                                      size: "sm",
                                    })}
                                    Xem Chi Tiết
                                </button>
                            </div>
                        </div>
                    </div>
                </section>
            </div>
        `;
  }

  async afterRender() {
    // Render all icons grid
    UI.icon.renderGrid("allIconsGrid");

    // Add test method to window for demo
    window.testCreateElement = () => {
      const icon = UI.icon.createElement("home", {
        size: "xl",
        color: "primary",
      });
      UI.toast.success("Icon element created! Check console.", "Success");
      console.log("Created icon element:", icon);
    };
  }
}

// Export component
if (typeof window !== "undefined") {
  window.IconShowcasePage = IconShowcasePage;
}
