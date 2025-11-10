// App routes & bootstrapping
import { Router } from "./app.js";

// lazy imports for components (demo)
const Home = () => import("./components/home.js");
const About = () => import("./components/about.js");
const Users = () => import("./components/users.js");
const NotFound = () => import("./components/404.js");

const routes = [
  { path: "/", component: Home, title: "Home - MiniSPA" },
  { path: "/about", component: About, title: "About - MiniSPA" },
  { path: "/users", component: Users, title: "Users - MiniSPA" },
  { path: "/users/:id", component: Users, title: "User detail - MiniSPA" },
  { path: "*", component: NotFound, title: "404 - Not Found" },
];

const router = new Router(routes);
router.start();

// expose navigate for debugging or programmatic navigation
window.router = router;
