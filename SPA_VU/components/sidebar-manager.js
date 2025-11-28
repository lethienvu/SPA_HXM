
class SidebarManager {
  constructor() {
    this.sidebar = document.getElementById("sidebar");
    this.toggleBtn = document.getElementById("sidebarToggleBtn");
    this.appContainer = document.getElementById("appContainer");
    this.storageKey = "paradiseHR_sidebarState";
    this.init();
  }

  init() {
    // Load saved state from localStorage
    this.loadState();

    // Add event listener to toggle button
    if (this.toggleBtn) {
      this.toggleBtn.addEventListener("click", () => this.toggle());
    } else {
      console.warn("⚠️ Toggle button not found!");
    }
  }

  /**
   * Load sidebar state from localStorage
   * Default state: expanded (false for collapsed)
   */
  loadState() {
    try {
      const savedState = localStorage.getItem(this.storageKey);
      const isCollapsed = savedState === "collapsed";

      if (isCollapsed) {
        this.collapse();
        this.appContainer.classList.add("sidebar-collapsed");
      } else {
        this.expand();
        this.appContainer.classList.remove("sidebar-collapsed");
      }
    } catch (error) {
      console.error("Error loading sidebar state:", error);
      this.expand(); // Default to expanded on error
    }
  }

  /**
   * Save sidebar state to localStorage
   */
  saveState(isCollapsed) {
    try {
      const state = isCollapsed ? "collapsed" : "expanded";
      localStorage.setItem(this.storageKey, state);
    } catch (error) {
      console.error("Error saving sidebar state:", error);
    }
  }

  /**
   * Toggle sidebar between expanded and collapsed states
   */
  toggle() {
    if (!this.sidebar) return;

    const isCurrentlyCollapsed = this.sidebar.classList.contains("collapsed");
    const isCurrentlyAppContainerCollapsed =
    this.appContainer.classList.contains("sidebar-collapsed");

    if (isCurrentlyCollapsed && isCurrentlyAppContainerCollapsed) {
      this.expand();
      this.appContainer.classList.remove("sidebar-collapsed");
    } else {
      this.collapse();
      this.appContainer.classList.add("sidebar-collapsed");
    }
  }

  /**
   * Expand sidebar
   */
  expand() {
    if (!this.sidebar) return;

    this.sidebar.classList.remove("collapsed");
    this.saveState(false);
    this.dispatchEvent("sidebarExpanded");
  }

  /**
   * Collapse sidebar
   */
  collapse() {
    if (!this.sidebar) return;

    this.sidebar.classList.add("collapsed");
    this.saveState(true);
    this.dispatchEvent("sidebarCollapsed");
  }

  /**
   * Get current state
   */
  isCollapsed() {
    return this.sidebar?.classList.contains("collapsed") ?? false;
  }

  /**
   * Dispatch custom events for other modules to listen to
   */
  dispatchEvent(eventName) {
    const event = new CustomEvent(eventName, {
      detail: { isCollapsed: this.isCollapsed() },
    });
    document.dispatchEvent(event);
  }

  /**
   * Force state (useful for responsive behavior)
   */
  setState(isCollapsed) {
    if (isCollapsed) {
      this.collapse();
    } else {
      this.expand();
    }
  }

  /**
   * Clear saved state and reset to default
   */
  resetState() {
    try {
      localStorage.removeItem(this.storageKey);
      this.expand();
    } catch (error) {
      console.error("Error resetting sidebar state:", error);
    }
  }

  /**
   * Get saved state from storage without applying it
   */
  getSavedState() {
    try {
      return localStorage.getItem(this.storageKey);
    } catch (error) {
      console.error("Error getting saved state:", error);
      return null;
    }
  }
}

// Initialize sidebar manager when DOM is ready
function initializeSidebarManager() {
  if (!window.sidebarManager) {
    window.sidebarManager = new SidebarManager();
  }
}

// Export to window for HTML access
window.initSidebarManager = initializeSidebarManager;

// Try to initialize immediately if DOM is ready
if (
  document.readyState === "complete" ||
  document.readyState === "interactive"
) {
  console.log("Initializing SidebarManager immediately...");
  initializeSidebarManager();
} else if (document.readyState === "loading") {
  // Wait for DOM
  document.addEventListener("DOMContentLoaded", initializeSidebarManager);
}

// Also set up initialization via script tag in HTML to ensure early init
window.initSidebarManager = initializeSidebarManager;

