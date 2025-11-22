// Core SPA framework (ES module)
class Component {
  constructor(props = {}) {
    this.props = props;
    this.el = document.createElement("div");
  }
  // override
  render() {
    return "";
  }
  // lifecycle hooks
  onMount() {}
  onUnmount() {}
  setHTML(html) {
    this.el.innerHTML = html;
    return this.el;
  }
}

function pathToRegex(path) {
  // Handle wildcard * as catch-all route (must be checked first)
  if (path === "*" || path === "/*") {
    return new RegExp(".*");
  }

  // convert /users/:id -> ^/users/([^/]+)$
  // Escape special regex characters except our placeholders
  const escapedPath = path
    .replace(/[.+?^${}()|[\]\\]/g, "\\$&") // Escape special chars
    .replace(/\\\*/g, ".*") // Convert \* back to .*
    .replace(/:(\w+)/g, "([^\\/]+)"); // Convert :param to capture group

  return new RegExp("^" + escapedPath + "$");
}

function getParams(match, route) {
  const values = match.slice(1);
  const keys = Array.from(route.path.matchAll(/:(\w+)/g)).map((m) => m[1]);
  const params = {};
  keys.forEach((k, i) => (params[k] = values[i]));
  return params;
}

class Router {
  constructor(routes = []) {
    this.routes = routes;
    this.currentComponent = null;
    this.outlet = document.getElementById("app");
    this.handleLinkClick = this.handleLinkClick.bind(this);
    this.onPopState = this.onPopState.bind(this);
    this.mode = "pushState" in history ? "history" : "hash";
  }

  start() {
    document.body.addEventListener("click", this.handleLinkClick);
    window.addEventListener("popstate", this.onPopState);
    window.addEventListener("hashchange", this.onPopState);
    this.navigate(this.getCurrentPath(), { replace: true });
  }

  stop() {
    document.body.removeEventListener("click", this.handleLinkClick);
    window.removeEventListener("popstate", this.onPopState);
    window.removeEventListener("hashchange", this.onPopState);
  }

  getCurrentPath() {
    if (this.mode === "history") {
      return location.pathname || "/";
    } else {
      return location.hash.replace("#", "") || "/";
    }
  }

  handleLinkClick(e) {
    // delegate link clicks with data-link attribute
    const a = e.target.closest("a[data-link]");
    if (!a) return;
    const href = a.getAttribute("href");
    if (!href) return;
    e.preventDefault();
    this.navigate(href);
  }

  onPopState() {
    this.navigate(this.getCurrentPath(), { replace: true, fromPop: true });
  }

  matchRoute(path) {
    for (const route of this.routes) {
      const regex = pathToRegex(route.path);
      const match = path.match(regex);
      if (match) {
        const params = getParams(match, route);
        return { route, params };
      }
    }
    return null;
  }

  async navigate(path, opts = {}) {
    const result = this.matchRoute(path);
    if (!result) {
      // try wildcard 404
      const notFound = this.routes.find((r) => r.path === "*");
      if (notFound) {
        return this.loadRoute(notFound, {}, opts);
      }
      console.warn("No route matched", path);
      return;
    }
    return this.loadRoute(result.route, result.params, opts);
  }

  async loadRoute(route, params = {}, opts = {}) {
    // Unmount previous
    if (this.currentComponent && this.currentComponent.onUnmount) {
      try {
        this.currentComponent.onUnmount();
      } catch (e) {
        console.error(e);
      }
    }

    // update history
    if (!opts.fromPop) {
      if (this.mode === "history") {
        if (opts.replace)
          history.replaceState(
            {},
            "",
            route.pathWithParams ? route.pathWithParams : route.path
          );
        else
          history.pushState(
            {},
            "",
            route.pathWithParams ? route.pathWithParams : route.path
          );
      } else {
        const hash = route.pathWithParams ? route.pathWithParams : route.path;
        if (opts.replace) location.replace("#" + hash);
        else location.hash = hash;
      }
    }

    let Comp = route.component;

    try {
      // Nếu component là function (có thể là lazy loader)
      if (typeof Comp === "function") {
        // Kiểm tra xem có phải là class constructor không
        if (Comp.prototype && Comp.prototype.constructor === Comp) {
          // Đây là class constructor, sử dụng trực tiếp
          // Không cần thay đổi gì
        } else {
          // Đây có thể là lazy loader function
          const result = Comp();
          if (result instanceof Promise) {
            // Async import
            const module = await result;
            Comp = module.default || module;
          } else {
            // Sync function return
            Comp = result;
          }
        }
      }

      // Tạo instance
      const instance = new Comp({ params, query: this._parseQuery() });
      this.currentComponent = instance;

      // render (string allowed)
      const html = await instance.render();
      this.outlet.innerHTML = "";
      this.outlet.appendChild(
        instance.setHTML(typeof html === "string" ? html : "")
      );

      if (instance.onMount) instance.onMount();
      if (route.title) document.title = route.title;
    } catch (error) {
      console.error("Error loading component:", error);
      console.error("Component type:", typeof Comp);
      console.error("Component:", Comp);

      // Fallback - hiển thị lỗi
      this.outlet.innerHTML = `
        <div style="padding: 20px; color: red; border: 1px solid red; margin: 20px;">
          <h3>Error Loading Component</h3>
          <p>Failed to load component for route: ${route.path}</p>
          <p>Error: ${error.message}</p>
        </div>
      `;
    }
  }

  _parseQuery() {
    const qs =
      this.mode === "history"
        ? location.search
        : location.hash.includes("?")
        ? location.hash.split("?")[1]
        : "";
    const params = new URLSearchParams(qs);
    const obj = {};
    for (const [k, v] of params.entries()) obj[k] = v;
    return obj;
  }
}

export { Component, Router };
