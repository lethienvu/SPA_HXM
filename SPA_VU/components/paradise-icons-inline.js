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
      tone1: `<path class="tone-1" d="M9.44669 15.3973C9.11392 15.1506 8.64421 15.2204 8.39755 15.5532C8.1509 15.8859 8.2207 16.3557 8.55347 16.6023C9.52588 17.3231 10.7151 17.7498 12.0001 17.7498C13.2851 17.7498 14.4743 17.3231 15.4467 16.6023C15.7795 16.3557 15.8493 15.8859 15.6026 15.5532C15.3559 15.2204 14.8862 15.1506 14.5535 15.3973C13.8251 15.9371 12.946 16.2498 12.0001 16.2498C11.0542 16.2498 10.175 15.9371 9.44669 15.3973Z"></path>`,
      tone2: `<path class="tone-2" fill-rule="evenodd" d="M12 1.25C11.2749 1.25 10.6134 1.44911 9.88928 1.7871C9.18832 2.11428 8.37772 2.59716 7.36183 3.20233L5.90622 4.06943C4.78711 4.73606 3.89535 5.26727 3.22015 5.77524C2.52314 6.29963 1.99999 6.8396 1.65907 7.55072C1.31799 8.26219 1.22554 9.0068 1.25519 9.87584C1.2839 10.717 1.43105 11.7397 1.61556 13.0219L1.90792 15.0537C2.14531 16.7036 2.33368 18.0128 2.61512 19.0322C2.90523 20.0829 3.31686 20.9169 4.05965 21.5565C4.80184 22.1956 5.68984 22.4814 6.77634 22.6177C7.83154 22.75 9.16281 22.75 10.8423 22.75H13.1577C14.8372 22.75 16.1685 22.75 17.2237 22.6177C18.3102 22.4814 19.1982 22.1956 19.9404 21.5565C20.6831 20.9169 21.0948 20.0829 21.3849 19.0322C21.6663 18.0129 21.8547 16.7036 22.0921 15.0537L22.3844 13.0219C22.569 11.7396 22.7161 10.717 22.7448 9.87584C22.7745 9.0068 22.682 8.26219 22.3409 7.55072C22 6.8396 21.4769 6.29963 20.7799 5.77524C20.1047 5.26727 19.2129 4.73606 18.0938 4.06943L16.6382 3.20233C15.6223 2.59716 14.8117 2.11428 14.1107 1.7871C13.3866 1.44911 12.7251 1.25 12 1.25ZM8.09558 4.51121C9.15309 3.88126 9.89923 3.43781 10.5237 3.14633C11.1328 2.86203 11.5708 2.75 12 2.75C12.4293 2.75 12.8672 2.86203 13.4763 3.14633C14.1008 3.43781 14.8469 3.88126 15.9044 4.51121L17.2893 5.33615C18.4536 6.02973 19.2752 6.52034 19.8781 6.9739C20.4665 7.41662 20.7888 7.78294 20.9883 8.19917C21.1877 8.61505 21.2706 9.09337 21.2457 9.82469C21.2201 10.5745 21.0856 11.5163 20.8936 12.8511L20.6148 14.7884C20.3683 16.5016 20.1921 17.7162 19.939 18.633C19.6916 19.5289 19.3939 20.0476 18.9616 20.4198C18.5287 20.7926 17.9676 21.0127 17.037 21.1294C16.086 21.2486 14.8488 21.25 13.1061 21.25H10.8939C9.15124 21.25 7.91405 21.2486 6.963 21.1294C6.03246 21.0127 5.47129 20.7926 5.03841 20.4198C4.60614 20.0476 4.30838 19.5289 4.06102 18.633C3.80791 17.7162 3.6317 16.5016 3.3852 14.7884L3.10643 12.851C2.91437 11.5163 2.77991 10.5745 2.75432 9.82469C2.72937 9.09337 2.81229 8.61505 3.01167 8.19917C3.21121 7.78294 3.53347 7.41662 4.12194 6.9739C4.72482 6.52034 5.54643 6.02973 6.71074 5.33615L8.09558 4.51121Z" clip-rule="evenodd"></path>`,
    },

    users: {
      tone1: `<path class="tone-1" d="M16,14C20.42,14 24,15.79 24,18V20H8V18C8,15.79 11.58,14 16,14M6,12C8.67,12 11,13.34 11,15V16H1V15C1,13.34 3.33,12 6,12Z"/>`,
      tone2: `<circle class="tone-2" cx="16" cy="8" r="4"/><circle class="tone-2" cx="6" cy="8" r="2"/>`,
    },

    userEdit: {
      tone1: `<path class="tone-1" d="M59.68 13.9A9.591 9.591 0 0050.1 4.32H42.61a1.5 1.5 0 000 3H50.1a6.588 6.588 0 016.58 6.58v7.49a1.5 1.5 0 003 0zM4.32 50.1a9.591 9.591 0 009.58 9.58h7.49a1.5 1.5 0 000-3H13.9A6.588 6.588 0 017.32 50.1V42.61a1.5 1.5 0 00-3 0zM21.39 4.32H13.9A9.591 9.591 0 004.32 13.9v7.49a1.5 1.5 0 003 0V13.9A6.588 6.588 0 0113.9 7.32h7.49a1.5 1.5 0 000-3zM42.61 59.68H50.1a9.591 9.591 0 009.58-9.58V42.61a1.5 1.5 0 00-3 0V50.1a6.588 6.588 0 01-6.58 6.58H42.61a1.5 1.5 0 000 3zM32 36.008a11.864 11.864 0 0111.851 11.85 11.41 11.41 0 01-.367 2.913A1.5 1.5 0 0044.555 52.6a1.521 1.521 0 00.382.048 1.5 1.5 0 001.45-1.119 14.509 14.509 0 00.464-3.675 14.851 14.851 0 00-29.7 0 14.509 14.509 0 00.464 3.675 1.5 1.5 0 102.9-.762 11.41 11.41 0 01-.367-2.913A11.864 11.864 0 0132 36.008z"></path>`,
      tone2: `<path class="tone-2" d="M32,11.348A10.15,10.15,0,1,0,42.15,21.5,10.161,10.161,0,0,0,32,11.348Zm0,17.3a7.15,7.15,0,1,1,7.15-7.15A7.159,7.159,0,0,1,32,28.648Z"></path>`,
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
