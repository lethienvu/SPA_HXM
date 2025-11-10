// Home component
import { Component } from "../app.js";

export default class Home extends Component {
  constructor(props) {
    super(props);
  }

  render() {
    return `
      <div class="p-4 bg-light rounded-3">
        <h1>Welcome to Mini SPA</h1>
        <p class="lead">Một framework SPA nhỏ mô phỏng routing, lifecycle và lazy-loading component.</p>
        <hr/>
        <p>Thử chuyển trang bằng thanh menu hoặc các link bên dưới.</p>
        <p>
          <a class="btn btn-primary" href="/about" data-link>About</a>
          <a class="btn btn-outline-primary ms-2" href="/users" data-link>Users</a>
        </p>
      </div>
    `;
  }
}
