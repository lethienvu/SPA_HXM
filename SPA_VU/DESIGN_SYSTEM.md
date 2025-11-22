# Paradise HR Design System

> **Modern HRM Design System** với glassmorphism effects, Apple-inspired aesthetics và smooth animations

## 🎨 Design Philosophy

- **Flat Design** với độ sâu tinh tế
- **Aesthetic trẻ trung** và chuyên nghiệp
- **Apple-inspired** rounded corners và spacing
- **Liquid Glass/Glassmorphism** elements
- **Accessibility-first** approach

---

## 🎯 1. COLOR PALETTE

### Brand Colors

```css
--brand-primary: #71C11D        /* Paradise Green */
--brand-primary-light: #8ED640  /* Hover states */
--brand-primary-dark: #5AA10F   /* Active states */
--brand-secondary: #004C39      /* Deep Forest */
--brand-accent: #FF8A00         /* Warm Orange */
```

**Usage Examples:**

```html
<!-- Primary Button -->
<button class="btn btn-primary btn-md">Submit</button>

<!-- Brand Logo -->
<div class="brand-logo" style="color: var(--brand-primary)">Paradise HR</div>
```

### Semantic Colors

```css
--color-success: #10B981    /* Success states */
--color-warning: #F59E0B    /* Warning alerts */
--color-error: #EF4444      /* Error messages */
--color-info: #3B82F6       /* Information */
```

### Neutral Palette

```css
--neutral-50: #FAFAFA      /* Lightest background */
--neutral-100: #F5F5F5     /* Light background */
--neutral-200: #E5E5E5     /* Border light */
--neutral-300: #D4D4D4     /* Border default */
--neutral-400: #A3A3A3     /* Disabled text */
--neutral-500: #737373     /* Muted text */
--neutral-600: #525252     /* Secondary text */
--neutral-700: #404040     /* Body text */
--neutral-800: #262626     /* Heading text */
--neutral-900: #171717     /* Primary text */
```

---

## ✍️ 2. TYPOGRAPHY SYSTEM

### Font Families

```css
--font-primary: -apple-system, BlinkMacSystemFont, 'SF Pro Display'
--font-secondary: -apple-system, BlinkMacSystemFont, 'SF Pro Text'
--font-mono: 'SF Mono', Monaco, 'Cascadia Code'
```

### Typography Scale

| Size        | CSS Value | Pixel | Usage                |
| ----------- | --------- | ----- | -------------------- |
| `text-xs`   | 0.75rem   | 12px  | Fine print, labels   |
| `text-sm`   | 0.875rem  | 14px  | Small text, captions |
| `text-base` | 1rem      | 16px  | Body text, default   |
| `text-lg`   | 1.125rem  | 18px  | Subheadings          |
| `text-xl`   | 1.25rem   | 20px  | Card titles          |
| `text-2xl`  | 1.5rem    | 24px  | Section headers      |
| `text-3xl`  | 1.875rem  | 30px  | Page titles          |
| `text-4xl`  | 2.25rem   | 36px  | Hero text            |
| `text-5xl`  | 3rem      | 48px  | Display text         |
| `text-6xl`  | 3.75rem   | 60px  | Marketing text       |

### Font Weights

```css
--font-light: 300      /* Light text */
--font-normal: 400     /* Body text */
--font-medium: 500     /* Emphasis */
--font-semibold: 600   /* Headings */
--font-bold: 700       /* Strong emphasis */
```

**Usage Examples:**

```html
<h1 style="font-size: var(--text-4xl); font-weight: var(--font-bold)">
  Dashboard Overview
</h1>
<p style="font-size: var(--text-base); font-weight: var(--font-normal)">
  Welcome to Paradise HR Management System
</p>
```

---

## 📐 3. SPACING SYSTEM (8px Grid)

### Spacing Scale

```css
--space-1: 0.25rem    /* 4px - Tight spacing */
--space-2: 0.5rem     /* 8px - Default gap */
--space-3: 0.75rem    /* 12px - Small padding */
--space-4: 1rem       /* 16px - Medium padding */
--space-6: 1.5rem     /* 24px - Large padding */
--space-8: 2rem       /* 32px - Section spacing */
--space-12: 3rem      /* 48px - Component spacing */
--space-16: 4rem      /* 64px - Layout spacing */
```

**Usage Examples:**

```html
<!-- Card with proper spacing -->
<div
  class="card"
  style="padding: var(--space-6); margin-bottom: var(--space-8)"
>
  <h3 style="margin-bottom: var(--space-4)">Employee Stats</h3>
  <div style="display: flex; gap: var(--space-3)">
    <span>Total: 1,247</span>
    <span>Active: 1,189</span>
  </div>
</div>
```

---

## 🔘 4. BORDER RADIUS SYSTEM

### Radius Scale

```css
--radius-xs: 0.25rem     /* 4px - Small elements */
--radius-sm: 0.5rem      /* 8px - Buttons small */
--radius-md: 0.75rem     /* 12px - Buttons medium */
--radius-lg: 1rem        /* 16px - Buttons large */
--radius-xl: 1.25rem     /* 20px - Cards */
--radius-2xl: 1.5rem     /* 24px - Modals */
--radius-3xl: 2rem       /* 32px - Hero sections */
--radius-full: 9999px    /* Circle elements */
```

**Component Specific:**

```css
--radius-button-sm: var(--radius-sm)    /* 8px */
--radius-button-md: var(--radius-md)    /* 12px */
--radius-button-lg: var(--radius-lg)    /* 16px */
--radius-card: var(--radius-xl)         /* 20px */
--radius-modal: var(--radius-2xl)       /* 24px */
--radius-input: var(--radius-md)        /* 12px */
```

---

## ✨ 5. GLASSMORPHISM SYSTEM

### Glass Backgrounds

```css
--glass-primary: rgba(255, 255, 255, 0.25)     /* Main glass */
--glass-secondary: rgba(255, 255, 255, 0.15)   /* Subtle glass */
--glass-tertiary: rgba(255, 255, 255, 0.08)    /* Light glass */
```

### Glass Borders

```css
--glass-border-light: rgba(255, 255, 255, 0.18)   /* Subtle border */
--glass-border-medium: rgba(255, 255, 255, 0.25)  /* Default border */
--glass-border-strong: rgba(255, 255, 255, 0.4)   /* Prominent border */
```

### Backdrop Blur Levels

```css
--blur-sm: blur(10px)    /* Subtle blur */
--blur-md: blur(20px)    /* Default blur */
--blur-lg: blur(40px)    /* Strong blur */
--blur-xl: blur(60px)    /* Maximum blur */
```

**Usage Examples:**

```html
<!-- Glass Card -->
<div class="card-glass">
  <div class="card-body">
    <h3>Glass Effect Card</h3>
    <p>Beautiful glassmorphism effect</p>
  </div>
</div>

<!-- Glass Button -->
<button class="btn btn-glass btn-md">Glass Button</button>

<!-- Utility Classes -->
<div class="glass-light">Light glass effect</div>
<div class="glass-medium">Medium glass effect</div>
<div class="glass-strong">Strong glass effect</div>
```

---

## 🎬 6. ANIMATION LIBRARY

### Duration Standards

```css
--duration-fast: 150ms      /* Quick interactions */
--duration-normal: 300ms    /* Standard transitions */
--duration-slow: 500ms      /* Emphasis transitions */
--duration-slower: 700ms    /* Complex animations */
```

### Easing Functions

```css
--ease-out: cubic-bezier(0.0, 0.0, 0.2, 1)          /* Natural deceleration */
--ease-in: cubic-bezier(0.4, 0.0, 1, 1)             /* Natural acceleration */
--ease-in-out: cubic-bezier(0.4, 0.0, 0.2, 1)       /* Smooth both ways */
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55) /* Bounce effect */
--ease-apple: cubic-bezier(0.2, 0.9, 0.3, 1)        /* Apple-style easing */
```

### Animation Classes

```html
<!-- Fade Animations -->
<div class="animate-fade-in">Fade in animation</div>
<div class="animate-fade-in-up">Fade in from bottom</div>
<div class="animate-fade-in-scale">Fade in with scale</div>

<!-- Slide Animations -->
<div class="animate-slide-in-right">Slide from right</div>
<div class="animate-slide-in-left">Slide from left</div>

<!-- Loading Animations -->
<div class="animate-spin">Spinning loader</div>
<div class="animate-pulse">Pulsing element</div>

<!-- Staggered Children -->
<div class="stagger-children">
  <div>Item 1 (0ms delay)</div>
  <div>Item 2 (100ms delay)</div>
  <div>Item 3 (200ms delay)</div>
</div>
```

### Hover Effects

```html
<!-- Hover Utilities -->
<div class="hover-lift">Lifts on hover</div>
<div class="hover-glow">Glows on hover</div>
```

---

## 🧩 7. COMPONENT SPECIFICATIONS

### Buttons

#### Primary Button

```html
<button class="btn btn-primary btn-md">
  <i class="bi bi-plus"></i>
  Add Employee
</button>
```

#### Secondary Button

```html
<button class="btn btn-secondary btn-md">Cancel</button>
```

#### Glass Button

```html
<button class="btn btn-glass btn-md">
  <i class="bi bi-search"></i>
  Search
</button>
```

#### Button Sizes

```html
<button class="btn btn-primary btn-sm">Small</button>
<button class="btn btn-primary btn-md">Medium</button>
<button class="btn btn-primary btn-lg">Large</button>
```

### Form Controls

#### Standard Input

```html
<div class="form-group">
  <label for="employee-name">Employee Name</label>
  <input
    type="text"
    id="employee-name"
    class="form-control"
    placeholder="Enter employee name"
  />
</div>
```

#### Glass Input

```html
<input
  type="email"
  class="form-control form-control-glass"
  placeholder="Enter email address"
/>
```

#### Input Sizes

```html
<input type="text" class="form-control form-control-sm" placeholder="Small" />
<input type="text" class="form-control" placeholder="Default" />
<input type="text" class="form-control form-control-lg" placeholder="Large" />
```

### Cards

#### Standard Card

```html
<div class="card">
  <div class="card-header">
    <h3>Employee Overview</h3>
  </div>
  <div class="card-body">
    <p>Card content goes here</p>
  </div>
  <div class="card-footer">
    <button class="btn btn-primary btn-sm">Action</button>
  </div>
</div>
```

#### Glass Card

```html
<div class="card-glass hover-lift">
  <div class="card-body">
    <h4>Glass Effect Card</h4>
    <p>Beautiful glassmorphism with hover lift effect</p>
  </div>
</div>
```

### Modals

#### Glass Modal

```html
<div class="modal-backdrop show">
  <div class="modal show">
    <div class="modal-header">
      <h3>Employee Details</h3>
      <button class="btn btn-ghost btn-sm">&times;</button>
    </div>
    <div class="modal-body">
      <p>Modal content with glassmorphism effect</p>
    </div>
    <div class="modal-footer">
      <button class="btn btn-secondary btn-md">Cancel</button>
      <button class="btn btn-primary btn-md">Save</button>
    </div>
  </div>
</div>
```

---

## 📱 8. RESPONSIVE BREAKPOINTS

```css
--breakpoint-sm: 640px     /* Mobile landscape */
--breakpoint-md: 768px     /* Tablet portrait */
--breakpoint-lg: 1024px    /* Tablet landscape */
--breakpoint-xl: 1280px    /* Desktop */
--breakpoint-2xl: 1536px   /* Large desktop */
```

### Usage Examples

```css
/* Mobile First Approach */
.component {
  padding: var(--space-4);
}

@media (min-width: 768px) {
  .component {
    padding: var(--space-6);
  }
}

@media (min-width: 1024px) {
  .component {
    padding: var(--space-8);
  }
}
```

---

## 🎯 9. SHADOW SYSTEM

### Standard Shadows

```css
--shadow-xs: 0 1px 2px rgba(0, 0, 0, 0.05)      /* Subtle */
--shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.1)       /* Small */
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.07)      /* Medium */
--shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.1)     /* Large */
--shadow-xl: 0 20px 25px rgba(0, 0, 0, 0.1)     /* Extra large */
```

### Glass Shadows

```css
--shadow-glass-sm: 0 4px 20px rgba(0, 0, 0, 0.06), 0 0 0 1px rgba(255, 255, 255, 0.05) inset
--shadow-glass-md: 0 8px 32px rgba(0, 0, 0, 0.1), 0 0 0 1px rgba(255, 255, 255, 0.05) inset
--shadow-glass-lg: 0 16px 64px rgba(0, 0, 0, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.1) inset
```

---

## ♿ 10. ACCESSIBILITY FEATURES

### Focus Management

```css
.focus-ring:focus-visible {
  outline: 2px solid var(--brand-primary);
  outline-offset: 2px;
}
```

### Screen Reader Support

```html
<span class="sr-only">Screen reader only text</span>
```

### Reduced Motion Support

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

### Color Contrast

All color combinations meet **WCAG 2.1 AA** standards:

- Primary text: 7:1 contrast ratio
- Secondary text: 4.5:1 contrast ratio
- Interactive elements: 3:1 contrast ratio

---

## 🚀 11. IMPLEMENTATION EXAMPLES

### Dashboard Header

```html
<header
  class="glass-light"
  style="padding: var(--space-6); border-radius: var(--radius-xl);"
>
  <div style="display: flex; align-items: center; gap: var(--space-4);">
    <div class="user-avatar" style="width: 48px; height: 48px;">VU</div>
    <div>
      <h2
        style="font-size: var(--text-xl); font-weight: var(--font-semibold); margin: 0;"
      >
        Welcome back, Thiên Vũ
      </h2>
      <p style="font-size: var(--text-sm); color: var(--text-secondary); margin: 0;">
        Human Resources Manager
      </p>
    </div>
  </div>
</header>
```

### Stats Card Grid

```html
<div
  style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: var(--space-6);"
>
  <div class="card-glass hover-lift">
    <div class="card-body">
      <div style="display: flex; align-items: center; gap: var(--space-3);">
        <div class="app-icon bg-primary">
          <i class="bi bi-people"></i>
        </div>
        <div>
          <h3
            style="font-size: var(--text-2xl); font-weight: var(--font-bold); margin: 0;"
          >
            1,247
          </h3>
          <p
            style="font-size: var(--text-sm); color: var(--text-secondary); margin: 0;"
          >
            Total Employees
          </p>
        </div>
      </div>
    </div>
  </div>

  <div class="card-glass hover-lift">
    <div class="card-body">
      <div style="display: flex; align-items: center; gap: var(--space-3);">
        <div class="app-icon bg-success">
          <i class="bi bi-check-circle"></i>
        </div>
        <div>
          <h3
            style="font-size: var(--text-2xl); font-weight: var(--font-bold); margin: 0;"
          >
            1,189
          </h3>
          <p
            style="font-size: var(--text-sm); color: var(--text-secondary); margin: 0;"
          >
            Active Employees
          </p>
        </div>
      </div>
    </div>
  </div>
</div>
```

### Action Form

```html
<form
  class="glass-medium"
  style="padding: var(--space-8); border-radius: var(--radius-2xl);"
>
  <h2
    style="font-size: var(--text-3xl); font-weight: var(--font-bold); margin-bottom: var(--space-6);"
  >
    Add New Employee
  </h2>

  <div style="display: grid; gap: var(--space-4);">
    <div>
      <label
        style="font-size: var(--text-sm); font-weight: var(--font-medium); margin-bottom: var(--space-2); display: block;"
      >
        Full Name
      </label>
      <input
        type="text"
        class="form-control form-control-glass"
        placeholder="Enter full name"
      />
    </div>

    <div>
      <label
        style="font-size: var(--text-sm); font-weight: var(--font-medium); margin-bottom: var(--space-2); display: block;"
      >
        Email Address
      </label>
      <input
        type="email"
        class="form-control form-control-glass"
        placeholder="Enter email address"
      />
    </div>

    <div
      style="display: flex; gap: var(--space-3); margin-top: var(--space-6);"
    >
      <button type="button" class="btn btn-secondary btn-md">Cancel</button>
      <button type="submit" class="btn btn-primary btn-md">
        <i class="bi bi-plus"></i>
        Add Employee
      </button>
    </div>
  </div>
</form>
```

---

## ⚡ 12. PERFORMANCE OPTIMIZATIONS

### CSS Performance

- Sử dụng `transform` và `opacity` cho animations
- Backdrop-filter được fallback cho browsers cũ
- Minimal repaints với `will-change` property

### Animation Performance

```css
.optimized-animation {
  will-change: transform, opacity;
  backface-visibility: hidden;
  perspective: 1000px;
}
```

### Browser Support

- **Safari**: Full glassmorphism support
- **Chrome/Edge**: Full support
- **Firefox**: Backdrop-filter fallback
- **Mobile**: iOS 9+, Android 5+

---

## 📋 13. USAGE CHECKLIST

### ✅ Do's

- Sử dụng spacing system (8px grid)
- Apply proper contrast ratios
- Implement focus states cho keyboard navigation
- Use semantic HTML elements
- Test animations với reduced motion
- Implement proper loading states

### ❌ Don'ts

- Không sử dụng fixed pixel values
- Không bỏ qua focus states
- Không overuse glassmorphism effects
- Không ignore mobile breakpoints
- Không sử dụng colors ngoài palette
- Không bỏ qua accessibility features

---

## 🔧 14. DEVELOPMENT TOOLS

### CSS Custom Properties Inspector

Sử dụng browser DevTools để inspect CSS variables:

```javascript
// Console command để xem all CSS variables
const root = getComputedStyle(document.documentElement);
console.log("--brand-primary:", root.getPropertyValue("--brand-primary"));
```

### Design Tokens Export

Các design tokens có thể export cho design tools:

- Figma tokens plugin
- Adobe XD design tokens
- Sketch symbols library

---

_Design System được tối ưu hóa cho Paradise HR - Human Experience Management_

**Version**: 1.0.0  
**Last Updated**: Tháng 11, 2025  
**Created by**: Lê Thiên Vũ
