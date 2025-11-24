/**
 * Paradise HR - Simplified Icon System
 * Using inline SVG content instead of sprite references
 */

class ParadiseIconsInline {
  static iconMap = {
    // Basic icons với simplified SVG
    notification: {
      tone1: `<path class="tone-1" d="M21 19V20H3V19L5 17V11C5 7.9 7.03 5.17 10 4.29C10 4.19 10 4.1 10 4C10 2.34 11.34 1 13 1C14.66 1 16 2.34 16 4C16 4.1 16 4.19 16 4.29C18.97 5.17 21 7.9 21 11V17L23 19Z"/>`,
      tone2: `<circle class="tone-2" cx="12" cy="4" r="2"/><path class="tone-2" d="M7 11C7 14.39 7.74 16.17 8.86 17H17.14C18.26 16.17 19 14.39 19 11C19 8.79 17.21 7 15 7H11C8.79 7 7 8.79 7 11Z"/>`,
    },

    settings: {
      tone1: `<path class="tone-1" d="M19.43,12.97C19.47,12.65 19.5,12.33 19.5,12C19.5,11.67 19.47,11.34 19.43,11L21.54,9.37C21.73,9.22 21.78,8.95 21.66,8.73L19.66,5.27C19.54,5.05 19.27,4.96 19.05,5.05L16.56,6.05C16.04,5.66 15.5,5.32 14.87,5.07L14.5,2.42C14.46,2.18 14.25,2 14,2H10C9.75,2 9.54,2.18 9.5,2.42L9.13,5.07C8.5,5.32 7.96,5.66 7.44,6.05L4.95,5.05C4.73,4.96 4.46,5.05 4.34,5.27L2.34,8.73C2.22,8.95 2.27,9.22 2.46,9.37L4.57,11C4.53,11.34 4.5,11.67 4.5,12C4.5,12.33 4.53,12.65 4.57,12.97L2.46,14.63C2.27,14.78 2.22,15.05 2.34,15.27L4.34,18.73C4.46,18.95 4.73,19.03 4.95,18.95L7.44,17.94C7.96,18.34 8.5,18.68 9.13,18.93L9.5,21.58C9.54,21.82 9.75,22 10,22H14C14.25,22 14.46,21.82 14.5,21.58L14.87,18.93C15.5,18.68 16.04,18.34 16.56,17.94L19.05,18.95C19.27,19.03 19.54,18.95 19.66,18.73L21.66,15.27C21.78,15.05 21.73,14.78 21.54,14.63L19.43,12.97Z"/>`,
      tone2: `<circle class="tone-2" cx="12" cy="12" r="3.5"/>`,
    },

    user: {
      tone1: `<circle class="tone-1" cx="12" cy="12" r="10" opacity=".3"/><circle cx="12" cy="10.14" r="3.8"/>`,
      tone2: `<circle class="tone-2" cx="11.81" cy="6.96" r="4.96"/>`,
    },

    home: {
      tone1: `<path class="tone-1"  d="M17.28 21.8H6.37a3.49 3.49 0 01-3.47-3.06L2 11.23a3.51 3.51 0 011.35-3.16L10 2.91a3.48 3.48 0 014.41.09l6.35 5.34A3.46 3.46 0 0122 11.59l-1.3 7.32a3.48 3.48 0 01-3.42 2.89z"/>`,
      tone2: `<circle class="tone-2" cx="12" cy="13.1" r="2.57"/>`,
    },

    users: {
      tone1: `<path class="tone-1" d="M16,14C20.42,14 24,15.79 24,18V20H8V18C8,15.79 11.58,14 16,14M6,12C8.67,12 11,13.34 11,15V16H1V15C1,13.34 3.33,12 6,12Z"/>`,
      tone2: `<circle class="tone-2" cx="16" cy="8" r="4"/><circle class="tone-2" cx="6" cy="8" r="2"/>`,
    },

    userEdit: {
      tone1: `<circle class="tone-1" cx="11.81" cy="6.96" r="4.96"/><path class="tone-1" d="M19.51 22a1.14 1.14 0 001.2-1.24c-.64-3.76-4.38-6.65-8.9-6.65S3.55 17 2.91 20.76A1.13 1.13 0 004.11 22z" />`,
      tone2: `<path class="tone-2" d="M16.81 19.73l-1.44.2a.7.7 0 01-.78-.83l.3-1.43a1.08 1.08 0 01.3-.54l3.41-3.19a1.09 1.09 0 011.54.09l.65.7a1.09 1.09 0 010 1.54l-3.41 3.19a1.09 1.09 0 01-.57.27z"/>`,
    },

    addItem: {
      tone1: `<rect class="tone-1" x="10.57" y="8" width="11.43" height="14" rx="2.97"/>`,
      tone2: `<path class="tone-2" d="M9.07 11a4.47 4.47 0 014.36-4.46V5a3 3 0 00-3-3H5a3 3 0 00-3 3v8a3 3 0 003 3h4.1zM18.13 14.25h-.88v-.88a.75.75 0 10-1.5 0v.88h-.88a.75.75 0 100 1.5h.88v.88a.75.75 0 001.5 0v-.88h.88a.75.75 0 000-1.5z"/>`,
    },

    calendar1: {
      tone1: `<path class="tone-1" d="M7 6a1 1 0 0 1-1-1V3a1 1 0 0 1 2 0v2a1 1 0 0 1-.999 1H7zm10 0a1 1 0 0 1-1-1V3a1 1 0 0 1 2 0v2a1 1 0 0 1-.999 1H17z"></path>
                <path class="tone-1" d="M19 4h-1v1a1 1 0 0 1-2 0V4H8v1a1 1 0 0 1-2 0V4H5a3 3 0 0 0-3 3v2h20V7a3 3 0 0 0-3-3z"></path>`,
      tone2: `<circle class="tone-2" cx="7" cy="13" r="1"></circle>
        <circle class="tone-2" cx="7" cy="17" r="1"></circle>
        <circle class="tone-2" cx="12" cy="13" r="1"></circle>
        <circle class="tone-2" cx="12" cy="17" r="1"></circle>
        <circle class="tone-2" cx="17" cy="13" r="1"></circle>
        <circle class="tone-2" cx="17" cy="17" r="1"></circle>
    <path class="tone-2" d="M2 9v10a3 3 0 0 0 3 3h14a3 3 0 0 0 3-3V9H2zm5 9a1 1 0 1 1 0-2 1 1 0 0 1 0 2zm0-4a1 1 0 1 1 0-2 1 1 0 0 1 0 2zm5 4a1 1 0 1 1 0-2 1 1 0 0 1 0 2zm0-4a1 1 0 1 1 0-2 1 1 0 0 1 0 2zm5 4a1 1 0 1 1 0-2 1 1 0 0 1 0 2zm0-4a1 1 0 1 1 0-2 1 1 0 0 1 0 2z"></path>`,
    },

    document: {
      tone1: `<path class="tone-1" d="M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2Z"/>`,
      tone2: `<path class="tone-2" d="M14,2V8H20L14,2Z"/>`,
    },

    calendar: {
      tone1: `<path class="tone-1" d="M19,3H18V1H16V3H8V1H6V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5A2,2 0 0,0 19,3M19,19H5V8H19V19Z"/>`,
      tone2: `<rect class="tone-2" x="7" y="10" width="5" height="5"/>`,
    },

    payroll: {
      tone1: `<circle class="tone-1" cx="12" cy="12" r="10"/>`,
      tone2: `<path class="tone-2" d="M7,15H9C9,16.08 10.37,17 12,17C13.63,17 15,16.08 15,15C15,13.9 13.96,13.5 11.76,12.97C9.64,12.44 7,11.78 7,9C7,7.21 8.47,5.69 10.5,5.18V3H13.5V5.18C15.53,5.69 17,7.21 17,9H15C15,7.92 13.63,7 12,7C10.37,7 9,7.92 9,9C9,10.1 10.04,10.5 12.24,11.03C14.36,11.56 17,12.22 17,15C17,16.79 15.53,18.31 13.5,18.82V21H10.5V18.82C8.47,18.31 7,16.79 7,15Z"/>`,
    },

    organization: {
      tone1: `<circle class="tone-1" cx="12" cy="8" r="6"/>`,
      tone2: `<path class="tone-2" d="M14,22V21A2,2 0 0,0 12,19H10A2,2 0 0,0 8,21V22H6V21A4,4 0 0,1 10,17H12A4,4 0 0,1 16,21V22H14M18,11A3,3 0 0,1 21,14A3,3 0 0,1 18,17A3,3 0 0,1 15,14A3,3 0 0,1 18,11M6,11A3,3 0 0,1 9,14A3,3 0 0,1 6,17A3,3 0 0,1 3,14A3,3 0 0,1 6,11Z"/>`,
    },

    component: {
      tone1: `<path class="tone-1" d="M12,2L2,7L12,12L22,7L12,2Z"/>`,
      tone2: `<path class="tone-2" d="M2,17L12,22L22,17L12,12L2,17Z"/>`,
    },

    close: {
      tone1: `<circle class="tone-1" cx="12" cy="12" r="10"/>`,
      tone2: `<path class="tone-2" d="M19,6.41L17.59,5L12,10.59L6.41,5L5,6.41L10.59,12L5,17.59L6.41,19L12,13.41L17.59,19L19,17.59L13.41,12L19,6.41Z"/>`,
    },
  };

  static createIcon(name, options = {}) {
    const {
      size = "md",
      className = "",
      interactive = false,
      ariaLabel = null,
      duotone = true,
    } = options;

    const iconData = this.iconMap[name];
    if (!iconData) {
      console.warn(`⚠️ Icon "${name}" not found in Paradise Icons`);
      return `<svg class="paradise-icon paradise-icon--${size} paradise-icon--fallback ${className}" viewBox="0 0 24 24" width="24" height="24">
        <circle fill="#ccc" cx="12" cy="12" r="10"/>
        <text x="12" y="16" text-anchor="middle" fill="white" font-size="8">?</text>
      </svg>`;
    }

    const classes = [
      "paradise-icon",
      duotone ? "icon--duotone" : "",
      `paradise-icon--${size}`,
      interactive ? "paradise-icon--interactive" : "",
      className,
    ]
      .filter(Boolean)
      .join(" ");

    // Create duotone icon content
    const iconContent =
      duotone && iconData.tone1 && iconData.tone2
        ? `${iconData.tone1}${iconData.tone2}`
        : iconData.tone2 || iconData; // fallback to tone2 or raw content

    return `<svg class="${classes}" viewBox="0 0 24 24" width="24" height="24" ${
      ariaLabel ? `aria-label="${ariaLabel}"` : 'aria-hidden="true"'
    }>
      ${iconContent}
    </svg>`;
  }

  static processDataIconElements() {
    const elements = document.querySelectorAll(
      "[data-icon]:not([data-icon-processed])"
    );
    console.log(`🔄 Processing ${elements.length} data-icon elements...`);

    elements.forEach((element, index) => {
      try {
        const iconName = element.getAttribute("data-icon");
        const size = element.getAttribute("data-icon-size") || "md";
        const interactive = element.hasAttribute("data-icon-interactive");
        const ariaLabel = element.getAttribute("data-icon-label");

        if (iconName) {
          const iconHTML = this.createIcon(iconName, {
            size,
            interactive,
            ariaLabel,
            className: element.getAttribute("data-icon-class") || "",
          });

          // Check if this is a navigation item with .nav-icon span
          const navIcon = element.querySelector(".nav-icon");
          if (navIcon) {
            // Only replace the nav-icon span content, preserve text
            navIcon.innerHTML = iconHTML;
            console.log(
              `✅ Processed nav icon ${index + 1}: ${iconName} (preserved text)`
            );
          } else {
            // For other elements (like navbar icons), replace entire content
            element.innerHTML = iconHTML;
            console.log(`✅ Processed icon ${index + 1}: ${iconName}`);
          }

          element.setAttribute("data-icon-processed", "true");
        }
      } catch (error) {
        console.error(`❌ Error processing icon ${index + 1}:`, error);
      }
    });
  }

  static init() {
    console.log("🚀 Paradise Icons Inline System initializing...");

    // Process existing elements
    this.processDataIconElements();

    // Watch for new elements
    const observer = new MutationObserver((mutations) => {
      let shouldProcess = false;
      mutations.forEach((mutation) => {
        if (mutation.type === "childList") {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === 1) {
              // Element node
              if (node.hasAttribute && node.hasAttribute("data-icon")) {
                shouldProcess = true;
              }
              // Check children
              if (node.querySelectorAll) {
                const iconElements = node.querySelectorAll(
                  "[data-icon]:not([data-icon-processed])"
                );
                if (iconElements.length > 0) {
                  shouldProcess = true;
                }
              }
            }
          });
        }
      });

      if (shouldProcess) {
        this.processDataIconElements();
      }
    });

    observer.observe(document.body, {
      childList: true,
      subtree: true,
    });

    console.log("✅ Paradise Icons Inline System initialized");
    return true;
  }
}

// Auto-initialize when DOM is ready
if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", () => {
    ParadiseIconsInline.init();
  });
} else {
  ParadiseIconsInline.init();
}

// Global API
window.ParadiseIconsInline = ParadiseIconsInline;
window.UI = window.UI || {};
window.UI.iconInline = ParadiseIconsInline;

// Debug tools
window.debugIconsInline = {
  test: (name) => {
    const div = document.createElement("div");
    div.innerHTML = ParadiseIconsInline.createIcon(name, { size: "lg" });
    document.body.appendChild(div);
    console.log(`🧪 Added test icon: ${name}`);
  },
  process: () => {
    // Remove all processed markers first
    document.querySelectorAll("[data-icon-processed]").forEach((el) => {
      el.removeAttribute("data-icon-processed");
      // Clear existing icons in nav-icon spans
      const navIcon = el.querySelector(".nav-icon");
      if (navIcon) {
        navIcon.innerHTML = "";
      }
    });
    ParadiseIconsInline.processDataIconElements();
    console.log("🔄 Force processed all icons");
  },
  check: () => {
    const elements = document.querySelectorAll("[data-icon]");
    const processed = document.querySelectorAll('[data-icon-processed="true"]');
    console.log(`📊 Total: ${elements.length}, Processed: ${processed.length}`);
    return { total: elements.length, processed: processed.length };
  },
};

console.log("🛠️ Debug tools: window.debugIconsInline");

export default ParadiseIconsInline;
