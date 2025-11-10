// 404 component
import { Component } from "../app.js";

export default class NotFound extends Component {
  render() {
    return `
      <div class="text-center">
        <h1 class="display-4">404</h1>
        <p class="lead">Page not found</p>
        <a class="btn btn-primary" href="/" data-link>Go Home</a>
      </div>
    `;
  }
}
