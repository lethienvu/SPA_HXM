/**
 * PARADISE HR - ICON HELPER
 * Helper functions để sử dụng SVG sprite icons
 */

class ParadiseIcon {
  /**
   * Tạo SVG icon element
   * @param {string} name - Tên icon (home, users, document, v.v.)
   * @param {Object} options - Options cho icon
   * @param {string} options.size - xs, sm, md, lg, xl, 2xl
   * @param {string} options.color - primary, secondary, dark, light, success, warning, danger, info
   * @param {string} options.className - Custom CSS classes
   * @param {boolean} options.interactive - Có hiệu ứng hover không
   * @param {string} options.animation - rotate, spin, pulse
   * @param {string} options.ariaLabel - Accessibility label
   * @returns {string} HTML string của icon
   */
  static create(name, options = {}) {
    const {
      size = "md",
      color = null,
      className = "",
      interactive = false,
      animation = null,
      ariaLabel = null,
    } = options;

    const classes = [
      "paradise-icon",
      `paradise-icon--${size}`,
      color ? `paradise-icon--${color}` : "",
      interactive ? "paradise-icon--interactive" : "",
      animation ? `paradise-icon--${animation}` : "",
      className,
    ]
      .filter(Boolean)
      .join(" ");

    const ariaAttrs = ariaLabel
      ? `role="img" aria-label="${ariaLabel}"`
      : 'aria-hidden="true"';

    // Cache busting for development
    const cacheBuster =
      process.env.NODE_ENV === "production" ? "" : `?v=${Date.now()}`;

    return `
            <svg class="${classes}" ${ariaAttrs}>
                <use href="/SPA_VU/assets/icons-sprite.svg${cacheBuster}#${name}"></use>
            </svg>
        `;
  }

  /**
   * Tạo icon element (DOM node)
   * @param {string} name - Tên icon
   * @param {Object} options - Options cho icon
   * @returns {SVGElement} SVG element
   */
  static createElement(name, options = {}) {
    const temp = document.createElement("div");
    temp.innerHTML = this.create(name, options).trim();
    return temp.firstChild;
  }

  /**
   * Tạo icon với container (có background, padding)
   * @param {string} name - Tên icon
   * @param {Object} options - Options
   * @param {string} options.containerSize - sm, md, lg
   * @param {string} options.containerVariant - primary, secondary, glass
   * @param {boolean} options.interactive - Interactive container
   * @returns {string} HTML string
   */
  static createWithContainer(name, options = {}) {
    const {
      size = "md",
      color = null,
      containerSize = "md",
      containerVariant = "glass",
      interactive = false,
      className = "",
      ariaLabel = null,
    } = options;

    const containerClasses = [
      "paradise-icon-container",
      `paradise-icon-container--${containerSize}`,
      `paradise-icon-container--${containerVariant}`,
      interactive ? "paradise-icon-container--interactive" : "",
      className,
    ]
      .filter(Boolean)
      .join(" ");

    const icon = this.create(name, { size, color, ariaLabel });

    return `
            <div class="${containerClasses}">
                ${icon}
            </div>
        `;
  }

  /**
   * Tạo icon với badge (notification count)
   * @param {string} name - Tên icon
   * @param {number|string} badge - Badge content
   * @param {Object} options - Options
   * @returns {string} HTML string
   */
  static createWithBadge(name, badge, options = {}) {
    const icon = this.create(name, options);

    return `
            <span class="paradise-icon-badge" data-badge="${badge}">
                ${icon}
            </span>
        `;
  }

  /**
   * Lấy danh sách tất cả icons có sẵn
   * @returns {Array<string>} Mảng tên icons
   */
  static getAvailableIcons() {
    return [
      "home",
      "users",
      "document",
      "calendar",
      "payroll",
      "organization",
      "settings",
      "notification",
      "search",
      "check",
      "close",
      "warning",
      "info",
      "upload",
      "download",
      "menu",
      "arrow-left",
      "arrow-right",
      "arrow-up",
      "arrow-down",
      "plus",
      "edit",
      "delete",
      "filter",
      "eye",
      "eye-off",
      "clock",
      "component",
      "loading",
    ];
  }

  /**
   * Render icon grid (để showcase/demo)
   * @param {string} containerId - ID của container element
   */
  static renderIconGrid(containerId) {
    const container = document.getElementById(containerId);
    if (!container) return;

    const icons = this.getAvailableIcons();
    const gridHTML = `
            <div class="paradise-icon-grid">
                ${icons
                  .map(
                    (icon) => `
                    <div class="paradise-icon-grid-item">
                        ${this.create(icon, { size: "lg", color: "primary" })}
                        <span class="paradise-icon-grid-label">${icon}</span>
                    </div>
                `
                  )
                  .join("")}
            </div>
        `;

    container.innerHTML = gridHTML;
  }

  /**
   * Replace Bootstrap Icons với Paradise Icons
   * @param {string} selector - CSS selector để tìm icons cần replace
   */
  static replaceBootstrapIcons(selector = ".bi") {
    const elements = document.querySelectorAll(selector);

    // Mapping từ Bootstrap icon class sang Paradise icon name
    const iconMap = {
      "bi-house": "home",
      "bi-house-fill": "home",
      "bi-people": "users",
      "bi-people-fill": "users",
      "bi-file-earmark": "document",
      "bi-file-earmark-text": "document",
      "bi-calendar": "calendar",
      "bi-calendar3": "calendar",
      "bi-cash-coin": "payroll",
      "bi-diagram-3": "organization",
      "bi-gear": "settings",
      "bi-gear-fill": "settings",
      "bi-bell": "notification",
      "bi-bell-fill": "notification",
      "bi-search": "search",
      "bi-check": "check",
      "bi-check-lg": "check",
      "bi-x": "close",
      "bi-x-lg": "close",
      "bi-exclamation-triangle": "warning",
      "bi-info-circle": "info",
      "bi-upload": "upload",
      "bi-download": "download",
      "bi-list": "menu",
      "bi-arrow-left": "arrow-left",
      "bi-arrow-right": "arrow-right",
      "bi-arrow-up": "arrow-up",
      "bi-arrow-down": "arrow-down",
      "bi-plus": "plus",
      "bi-plus-lg": "plus",
      "bi-pencil": "edit",
      "bi-trash": "delete",
      "bi-filter": "filter",
      "bi-eye": "eye",
      "bi-eye-slash": "eye-off",
      "bi-clock": "clock",
      "bi-box-seam": "component",
    };

    elements.forEach((element) => {
      // Tìm Bootstrap icon class
      const classList = Array.from(element.classList);
      const biClass = classList.find((c) => c.startsWith("bi-"));

      if (biClass && iconMap[biClass]) {
        const iconName = iconMap[biClass];
        const size = element.classList.contains("bi-sm")
          ? "sm"
          : element.classList.contains("bi-lg")
          ? "lg"
          : "md";

        // Tạo Paradise icon
        const icon = this.createElement(iconName, { size });

        // Replace element
        element.parentNode.replaceChild(icon, element);
      }
    });
  }
}

// Export để sử dụng trong các module khác
if (typeof window !== "undefined") {
  window.ParadiseIcon = ParadiseIcon;
}

// Thêm vào UI global object
if (typeof UI !== "undefined") {
  UI.icon = {
    /**
     * Tạo icon HTML
     */
    create: (name, options) => ParadiseIcon.create(name, options),

    /**
     * Tạo icon DOM element
     */
    createElement: (name, options) => ParadiseIcon.createElement(name, options),

    /**
     * Tạo icon với container
     */
    withContainer: (name, options) =>
      ParadiseIcon.createWithContainer(name, options),

    /**
     * Tạo icon với badge
     */
    withBadge: (name, badge, options) =>
      ParadiseIcon.createWithBadge(name, badge, options),

    /**
     * Lấy danh sách icons
     */
    list: () => ParadiseIcon.getAvailableIcons(),

    /**
     * Render icon grid
     */
    renderGrid: (containerId) => ParadiseIcon.renderIconGrid(containerId),

    /**
     * Replace Bootstrap Icons
     */
    replaceBootstrapIcons: (selector) =>
      ParadiseIcon.replaceBootstrapIcons(selector),
  };
}

/**
 * USAGE EXAMPLES:
 *
 * 1. Basic icon:
 *    UI.icon.create('home')
 *    UI.icon.create('users', { size: 'lg', color: 'primary' })
 *
 * 2. Interactive icon:
 *    UI.icon.create('settings', { interactive: true, animation: 'rotate' })
 *
 * 3. Icon with container:
 *    UI.icon.withContainer('notification', { containerVariant: 'primary' })
 *
 * 4. Icon with badge:
 *    UI.icon.withBadge('notification', 5, { color: 'primary' })
 *
 * 5. Create DOM element:
 *    const icon = UI.icon.createElement('home', { size: 'lg' });
 *    document.body.appendChild(icon);
 *
 * 6. Show all icons:
 *    UI.icon.renderGrid('icon-container');
 *
 * 7. Replace Bootstrap Icons:
 *    UI.icon.replaceBootstrapIcons('.bi');
 */
