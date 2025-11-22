/**
 * PARADISE HR - PROFESSIONAL ICON SYSTEM
 * Component-based icon system với auto initialization và easy maintenance
 */

class ParadiseIconSystem {
  constructor() {
    this.isInitialized = false;
    this.spriteLoaded = false;
    this.observerConfig = { childList: true, subtree: true };
    this.mutationObserver = null;
  }

  /**
   * Initialize icon system
   */
  async init() {
    if (this.isInitialized) return;

    try {
      // Load SVG sprite
      await this.loadSprite();

      // Process existing icons
      this.processAllIcons();

      // Setup mutation observer for dynamic content
      this.setupMutationObserver();

      // Mark as initialized
      this.isInitialized = true;

      console.log("✅ Paradise Icon System initialized successfully");
    } catch (error) {
      console.error("❌ Failed to initialize Paradise Icon System:", error);
    }
  }

  /**
   * Load SVG sprite into DOM
   */
  async loadSprite() {
    if (this.spriteLoaded) return;

    try {
      const response = await fetch("./assets/icons-sprite.svg");
      if (!response.ok) throw new Error(`HTTP ${response.status}`);

      const svgContent = await response.text();

      // Create hidden container
      const container = document.createElement("div");
      container.style.display = "none";
      container.innerHTML = svgContent;

      // Insert at beginning of body
      document.body.insertBefore(container, document.body.firstChild);

      this.spriteLoaded = true;
      console.log("✅ SVG sprite loaded");
    } catch (error) {
      console.error("❌ Failed to load SVG sprite:", error);
      throw error;
    }
  }

  /**
   * Setup mutation observer để tự động process icons mới
   */
  setupMutationObserver() {
    this.mutationObserver = new MutationObserver((mutations) => {
      let hasNewIcons = false;

      mutations.forEach((mutation) => {
        if (mutation.type === "childList") {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              if (this.hasIconElements(node)) {
                hasNewIcons = true;
              }
            }
          });
        }
      });

      if (hasNewIcons) {
        requestAnimationFrame(() => this.processAllIcons());
      }
    });

    this.mutationObserver.observe(document.body, this.observerConfig);
  }

  /**
   * Check if element or its children have icon elements
   */
  hasIconElements(element) {
    return (
      element.hasAttribute("data-icon") ||
      element.querySelector("[data-icon]") ||
      element.classList.contains("paradise-icon-placeholder")
    );
  }

  /**
   * Process all icons trong DOM
   */
  processAllIcons() {
    // Process data-icon attributes
    this.processDataIconElements();

    // Process icon placeholders
    this.processIconPlaceholders();

    // Process navbar icons
    this.processNavbarIcons();
  }

  /**
   * Process elements with data-icon attribute
   */
  processDataIconElements() {
    const elements = document.querySelectorAll(
      "[data-icon]:not([data-icon-processed])"
    );

    elements.forEach((element) => {
      const iconName = element.getAttribute("data-icon");
      const size = element.getAttribute("data-icon-size") || "sm";
      const color = element.getAttribute("data-icon-color") || null;
      const interactive = element.hasAttribute("data-icon-interactive");
      const animation = element.getAttribute("data-icon-animation") || null;

      // Find icon container or create one
      let iconContainer = element.querySelector(".icon-container, .nav-icon");
      if (!iconContainer) {
        iconContainer = document.createElement("span");
        iconContainer.className = "icon-container";
        element.insertBefore(iconContainer, element.firstChild);
      }

      // Create icon
      const iconHTML = this.createIcon(iconName, {
        size,
        color,
        interactive,
        animation,
      });

      iconContainer.innerHTML = iconHTML;
      element.setAttribute("data-icon-processed", "true");
    });
  }

  /**
   * Process placeholder elements
   */
  processIconPlaceholders() {
    const placeholders = document.querySelectorAll(
      ".paradise-icon-placeholder:not([data-processed])"
    );

    placeholders.forEach((placeholder) => {
      const iconName = placeholder.getAttribute("data-name");
      const size = placeholder.getAttribute("data-size") || "md";
      const color = placeholder.getAttribute("data-color") || null;
      const withBadge = placeholder.getAttribute("data-badge");
      const containerVariant = placeholder.getAttribute("data-container");

      let iconHTML;

      if (withBadge) {
        iconHTML = this.createIconWithBadge(iconName, withBadge, {
          size,
          color,
        });
      } else if (containerVariant) {
        iconHTML = this.createIconWithContainer(iconName, {
          size,
          color,
          containerVariant,
        });
      } else {
        iconHTML = this.createIcon(iconName, { size, color });
      }

      placeholder.outerHTML = iconHTML;
    });
  }

  /**
   * Process specific navbar icons
   */
  processNavbarIcons() {
    // Search icon
    const searchContainer = document.querySelector(
      ".navbar-search .position-relative"
    );
    if (searchContainer && !searchContainer.querySelector(".paradise-icon")) {
      const searchIcon = this.createElement("search", { size: "sm" });
      searchIcon.style.position = "absolute";
      searchIcon.style.left = "12px";
      searchIcon.style.top = "50%";
      searchIcon.style.transform = "translateY(-50%)";
      searchIcon.style.pointerEvents = "none";
      searchIcon.style.color = "#6b7280";
      searchContainer.appendChild(searchIcon);

      // Add padding to input
      const input = searchContainer.querySelector("input");
      if (input) {
        input.style.paddingLeft = "40px";
      }
    }

    // Notification icon with badge
    const notificationLink = document.querySelector(
      '.nav-link[href="#"]:first-of-type'
    );
    if (notificationLink && !notificationLink.querySelector(".paradise-icon")) {
      notificationLink.innerHTML = this.createIconWithBadge("notification", 5, {
        size: "lg",
        color: "primary",
      });
    }

    // Settings icon
    const settingsLink = document.querySelector(
      '.nav-link[href="#"]:nth-of-type(2)'
    );
    if (settingsLink && !settingsLink.querySelector(".paradise-icon")) {
      settingsLink.innerHTML = this.createIcon("settings", { size: "lg" });
    }

    // Profile icon
    const profileLink = document.querySelector(
      '.nav-link[href="#"]:last-of-type'
    );
    if (profileLink && !profileLink.querySelector(".paradise-icon")) {
      profileLink.innerHTML = this.createIcon("users", { size: "lg" });
    }
  }

  /**
   * Create icon HTML string
   */
  createIcon(name, options = {}) {
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

    return `
        <svg class="${classes}" ${ariaAttrs}>
          <use href="#icon-${name}"></use>
        </svg>
      `;
  }

  /**
   * Create icon DOM element
   */
  createElement(name, options = {}) {
    const temp = document.createElement("div");
    temp.innerHTML = this.createIcon(name, options).trim();
    return temp.firstElementChild;
  }

  /**
   * Create icon with container
   */
  createIconWithContainer(name, options = {}) {
    const {
      size = "md",
      color = null,
      containerSize = "md",
      containerVariant = "glass",
      interactive = false,
      className = "",
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

    const icon = this.createIcon(name, { size, color });

    return `
            <div class="${containerClasses}">
                ${icon}
            </div>
        `;
  }

  /**
   * Create icon with badge
   */
  createIconWithBadge(name, badge, options = {}) {
    const icon = this.createIcon(name, options);

    return `
            <span class="paradise-icon-badge" data-badge="${badge}">
                ${icon}
            </span>
        `;
  }

  /**
   * Get available icons
   */
  getAvailableIcons() {
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
   * Refresh/re-process all icons
   */
  refresh() {
    // Remove processed markers
    document.querySelectorAll("[data-icon-processed]").forEach((el) => {
      el.removeAttribute("data-icon-processed");
    });

    document.querySelectorAll("[data-processed]").forEach((el) => {
      el.removeAttribute("data-processed");
    });

    // Re-process
    this.processAllIcons();
  }

  /**
   * Destroy icon system
   */
  destroy() {
    if (this.mutationObserver) {
      this.mutationObserver.disconnect();
      this.mutationObserver = null;
    }

    this.isInitialized = false;
    this.spriteLoaded = false;
  }
}

// Create global instance
const ParadiseIcons = new ParadiseIconSystem();

// Auto-initialize when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => ParadiseIcons.init());
} else {
  ParadiseIcons.init();
}

// Expose to global scope
if (typeof window !== "undefined") {
  window.ParadiseIcons = ParadiseIcons;

  // Maintain backward compatibility with old UI.icon API
  if (typeof UI !== "undefined") {
    UI.icon = {
      create: (name, options) => ParadiseIcons.createIcon(name, options),
      createElement: (name, options) =>
        ParadiseIcons.createElement(name, options),
      withContainer: (name, options) =>
        ParadiseIcons.createIconWithContainer(name, options),
      withBadge: (name, badge, options) =>
        ParadiseIcons.createIconWithBadge(name, badge, options),
      list: () => ParadiseIcons.getAvailableIcons(),
      refresh: () => ParadiseIcons.refresh(),
    };
  }
}

// For CommonJS compatibility
if (typeof module !== "undefined" && module.exports) {
  module.exports = ParadiseIcons;
}
