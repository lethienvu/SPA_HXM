#!/usr/bin/env python3
"""
SPA Migration Tool
==================
Tool để migrate source code SPA_VU vào SQL Server tables theo architecture hybrid.

Usage:
    python spa_migrator.py --action migrate --component dashboard --db-server localhost --db-name Paradise_HPSF
    python spa_migrator.py --action migrate-all --source-dir ./SPA_VU --db-server localhost --db-name Paradise_HPSF
    python spa_migrator.py --action register --component leave-list --route /leave --menu MnuWPT200
"""

import os
import sys
import json
import re
import argparse
import pyodbc
from pathlib import Path
from typing import Dict, List, Optional, Tuple
import logging

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

class SPAMigrator:
    def __init__(self, db_server: str, db_name: str, db_user: str = None, db_password: str = None):
        """Initialize SPA Migrator with database connection"""
        self.db_server = db_server
        self.db_name = db_name
        self.db_user = db_user
        self.db_password = db_password
        self.connection = None
        
        # Component mapping từ file name -> menu ID
        self.component_mapping = {
            'home': {'id': 'dashboard', 'route': '/', 'menu': 'MnuHRS2000', 'title': 'Dashboard'},
            'dashboard': {'id': 'dashboard', 'route': '/', 'menu': 'MnuHRS2000', 'title': 'Dashboard'},
            'about': {'id': 'about', 'route': '/about', 'menu': 'MnuHRS2001', 'title': 'About'},
            'users': {'id': 'employees', 'route': '/employees', 'menu': 'MnuHRS100', 'title': 'Employees'},
            'employees': {'id': 'employees', 'route': '/employees', 'menu': 'MnuHRS100', 'title': 'Employees'},
            'requests': {'id': 'requests', 'route': '/requests', 'menu': 'MnuWPT100', 'title': 'Create Request'},
            'attendance': {'id': 'attendance', 'route': '/attendance', 'menu': 'MnuWPT206', 'title': 'Attendance'},
            'payroll': {'id': 'payroll', 'route': '/payroll', 'menu': 'MnuHRS200', 'title': 'Payroll'},
            'organization': {'id': 'organization', 'route': '/organization', 'menu': 'MnuHRS300', 'title': 'Organization Chart'},
            '404': {'id': 'not-found', 'route': '*', 'menu': None, 'title': 'Page Not Found'}
        }
        
    def connect_db(self):
        """Establish database connection"""
        try:
            if self.db_user and self.db_password:
                conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={self.db_server};DATABASE={self.db_name};UID={self.db_user};PWD={self.db_password}"
            else:
                conn_str = f"DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={self.db_server};DATABASE={self.db_name};Trusted_Connection=yes"
            
            self.connection = pyodbc.connect(conn_str)
            logger.info(f"Connected to database: {self.db_name}")
            return True
            
        except Exception as e:
            logger.error(f"Database connection failed: {e}")
            return False
    
    def close_db(self):
        """Close database connection"""
        if self.connection:
            self.connection.close()
            logger.info("Database connection closed")
    
    def parse_javascript_component(self, file_path: str) -> Dict:
        """Parse JavaScript component file to extract HTML template"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract component name
            file_name = Path(file_path).stem
            
            # Extract HTML template from render() method
            html_pattern = r'render\s*\(\s*\)\s*\{\s*return\s*`([^`]*)`'
            html_match = re.search(html_pattern, content, re.DOTALL)
            html_template = html_match.group(1).strip() if html_match else ""
            
            # Extract class name
            class_pattern = r'(?:export\s+default\s+)?class\s+(\w+)\s+extends\s+Component'
            class_match = re.search(class_pattern, content)
            class_name = class_match.group(1) if class_match else f"{file_name.title()}Component"
            
            # Extract methods (onMount, onUnmount, etc.)
            methods = []
            method_pattern = r'(\w+)\s*\([^)]*\)\s*\{[^}]*\}'
            method_matches = re.finditer(method_pattern, content)
            
            for match in method_matches:
                method_name = match.group(1)
                if method_name not in ['render', 'constructor']:
                    methods.append(match.group(0))
            
            return {
                'file_name': file_name,
                'class_name': class_name,
                'html_template': html_template,
                'methods': methods,
                'full_content': content
            }
            
        except Exception as e:
            logger.error(f"Error parsing {file_path}: {e}")
            return {}
    
    def parse_css_file(self, file_path: str) -> str:
        """Parse CSS file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except Exception as e:
            logger.error(f"Error reading CSS file {file_path}: {e}")
            return ""
    
    def parse_routes_from_main(self, main_js_path: str) -> List[Dict]:
        """Parse routes from main.js file"""
        try:
            with open(main_js_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Extract routes array
            routes_pattern = r'const\s+routes\s*=\s*\[(.*?)\];'
            routes_match = re.search(routes_pattern, content, re.DOTALL)
            
            if not routes_match:
                logger.warning("No routes found in main.js")
                return []
            
            routes_content = routes_match.group(1)
            
            # Parse individual route objects
            route_pattern = r'\{\s*path:\s*["\']([^"\']+)["\']\s*,\s*component:\s*(\w+)\s*,\s*title:\s*["\']([^"\']+)["\']\s*\}'
            route_matches = re.finditer(route_pattern, routes_content)
            
            routes = []
            for match in route_matches:
                path, component_class, title = match.groups()
                routes.append({
                    'path': path,
                    'component_class': component_class,
                    'title': title
                })
            
            return routes
            
        except Exception as e:
            logger.error(f"Error parsing routes from {main_js_path}: {e}")
            return []
    
    def component_exists(self, component_id: str) -> bool:
        """Check if component exists in database"""
        try:
            cursor = self.connection.cursor()
            cursor.execute("SELECT COUNT(*) FROM tblSPA_Components WHERE ComponentID = ?", component_id)
            count = cursor.fetchone()[0]
            return count > 0
        except Exception as e:
            logger.error(f"Error checking component existence: {e}")
            return False
    
    def insert_component(self, component_data: Dict) -> bool:
        """Insert new component into database"""
        try:
            cursor = self.connection.cursor()
            
            # Insert component record
            sql = """
            INSERT INTO tblSPA_Components (
                ComponentID, ComponentName, ComponentType, RoutePattern, 
                MenuID, StoredProcedure, PreloadJS, RequireAuth, IsActive, CreatedDate
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
            """
            
            cursor.execute(sql, (
                component_data['id'],
                component_data['name'],
                component_data.get('type', 'page'),
                component_data['route'],
                component_data.get('menu_id'),
                component_data.get('stored_procedure'),
                component_data.get('preload_js', 0),
                component_data.get('require_auth', 1),
                1  # IsActive
            ))
            
            # Insert templates
            if component_data.get('html_template'):
                cursor.execute("""
                    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, IsActive)
                    VALUES (?, 'html', ?, 1)
                """, (component_data['id'], component_data['html_template']))
            
            if component_data.get('css_template'):
                cursor.execute("""
                    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, IsActive)
                    VALUES (?, 'css', ?, 1)
                """, (component_data['id'], component_data['css_template']))
            
            if component_data.get('js_template'):
                cursor.execute("""
                    INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, IsActive)
                    VALUES (?, 'js', ?, 1)
                """, (component_data['id'], component_data['js_template']))
            
            self.connection.commit()
            logger.info(f"✅ Inserted component: {component_data['id']}")
            return True
            
        except Exception as e:
            logger.error(f"Error inserting component {component_data['id']}: {e}")
            self.connection.rollback()
            return False
    
    def update_component(self, component_data: Dict) -> bool:
        """Update existing component in database"""
        try:
            cursor = self.connection.cursor()
            
            # Update component record
            sql = """
            UPDATE tblSPA_Components 
            SET ComponentName = ?, ComponentType = ?, RoutePattern = ?, 
                MenuID = ?, StoredProcedure = ?, PreloadJS = ?, 
                RequireAuth = ?, ModifiedDate = GETDATE()
            WHERE ComponentID = ?
            """
            
            cursor.execute(sql, (
                component_data['name'],
                component_data.get('type', 'page'),
                component_data['route'],
                component_data.get('menu_id'),
                component_data.get('stored_procedure'),
                component_data.get('preload_js', 0),
                component_data.get('require_auth', 1),
                component_data['id']
            ))
            
            # Update templates
            for template_type in ['html', 'css', 'js']:
                template_key = f'{template_type}_template'
                if component_data.get(template_key):
                    # Delete existing template
                    cursor.execute("""
                        DELETE FROM tblSPA_Templates 
                        WHERE ComponentID = ? AND TemplateType = ?
                    """, (component_data['id'], template_type))
                    
                    # Insert new template
                    cursor.execute("""
                        INSERT INTO tblSPA_Templates (ComponentID, TemplateType, TemplateContent, IsActive)
                        VALUES (?, ?, ?, 1)
                    """, (component_data['id'], template_type, component_data[template_key]))
            
            self.connection.commit()
            logger.info(f"🔄 Updated component: {component_data['id']}")
            return True
            
        except Exception as e:
            logger.error(f"Error updating component {component_data['id']}: {e}")
            self.connection.rollback()
            return False
    
    def generate_js_template(self, parsed_component: Dict, component_id: str) -> str:
        """Generate JavaScript template for component"""
        class_name = parsed_component['class_name']
        html_template = parsed_component['html_template'].replace('`', '\\`').replace('${', '\\${')
        
        js_template = f"""
class {class_name} extends Component {{
    async render() {{
        // Get data if needed
        const data = this.props.data ? JSON.parse(this.props.data) : {{}};
        
        // Template
        let html = `{html_template}`;
        
        // Replace placeholders with data
        // html = html.replace('{{{{placeholder}}}}', data.value || 'default');
        
        return html;
    }}
    
    onMount() {{
        // Component mounted - add event listeners, start timers, etc.
        console.log('{class_name} mounted');
    }}
    
    onUnmount() {{
        // Component unmounted - cleanup
        console.log('{class_name} unmounted');
    }}
    
    async loadData() {{
        // Override to load component-specific data
        try {{
            const response = await fetch('/api/component-data', {{
                method: 'POST',
                headers: {{ 'Content-Type': 'application/json' }},
                body: JSON.stringify({{
                    componentId: '{component_id}',
                    params: this.props.params || {{}}
                }})
            }});
            return response.json();
        }} catch (error) {{
            console.error('Error loading data:', error);
            return {{}};
        }}
    }}
}}

// Make available globally
window.ComponentClass = {class_name};
        """.strip()
        
        return js_template
    
    def migrate_component(self, source_dir: str, component_name: str) -> bool:
        """Migrate a single component from source to database"""
        try:
            # Get component mapping
            if component_name not in self.component_mapping:
                logger.error(f"Unknown component: {component_name}")
                return False
            
            mapping = self.component_mapping[component_name]
            component_id = mapping['id']
            
            # Parse JavaScript file
            js_path = Path(source_dir) / 'components' / f'{component_name}.js'
            if not js_path.exists():
                # Try in main.js for embedded components
                js_path = Path(source_dir) / 'main.js'
            
            if not js_path.exists():
                logger.error(f"Component file not found: {js_path}")
                return False
            
            parsed_component = self.parse_javascript_component(str(js_path))
            if not parsed_component:
                return False
            
            # Parse CSS (optional)
            css_path = Path(source_dir) / 'styles.css'
            css_content = self.parse_css_file(str(css_path)) if css_path.exists() else ""
            
            # Build component data
            component_data = {
                'id': component_id,
                'name': mapping['title'],
                'type': 'page',
                'route': mapping['route'],
                'menu_id': mapping['menu'],
                'html_template': parsed_component['html_template'],
                'css_template': css_content if component_name == 'home' else "",  # Only include CSS for main component
                'js_template': self.generate_js_template(parsed_component, component_id),
                'preload_js': 1 if component_name in ['home', 'dashboard'] else 0,
                'require_auth': 0 if component_name in ['404'] else 1
            }
            
            # Insert or Update
            if self.component_exists(component_id):
                return self.update_component(component_data)
            else:
                return self.insert_component(component_data)
                
        except Exception as e:
            logger.error(f"Error migrating component {component_name}: {e}")
            return False
    
    def migrate_all_components(self, source_dir: str) -> Dict[str, int]:
        """Migrate all components from source directory"""
        results = {'success': 0, 'failed': 0, 'errors': []}
        
        # Get all component files
        components_dir = Path(source_dir) / 'components'
        if not components_dir.exists():
            logger.error(f"Components directory not found: {components_dir}")
            return results
        
        # Find all .js files
        for js_file in components_dir.glob('*.js'):
            component_name = js_file.stem
            
            if component_name in self.component_mapping:
                logger.info(f"Migrating component: {component_name}")
                
                if self.migrate_component(source_dir, component_name):
                    results['success'] += 1
                else:
                    results['failed'] += 1
                    results['errors'].append(f"Failed to migrate {component_name}")
            else:
                logger.warning(f"Skipping unknown component: {component_name}")
        
        return results
    
    def register_component_manual(self, component_id: str, component_name: str, 
                                route: str, menu_id: str = None, 
                                component_type: str = 'page') -> bool:
        """Manually register a component without source files"""
        try:
            component_data = {
                'id': component_id,
                'name': component_name,
                'type': component_type,
                'route': route,
                'menu_id': menu_id,
                'html_template': f'<div class="{component_id}-container"><h2>{component_name}</h2><p>Component content goes here</p></div>',
                'js_template': f"""
class {component_name.replace(' ', '')}Component extends Component {{
    async render() {{
        return `<div class="{component_id}-container">
            <h2>{component_name}</h2>
            <p>Component content goes here</p>
        </div>`;
    }}
}}
window.ComponentClass = {component_name.replace(' ', '')}Component;
                """.strip(),
                'preload_js': 0,
                'require_auth': 1
            }
            
            if self.component_exists(component_id):
                return self.update_component(component_data)
            else:
                return self.insert_component(component_data)
                
        except Exception as e:
            logger.error(f"Error registering component {component_id}: {e}")
            return False
    
    def list_components(self) -> List[Dict]:
        """List all components in database"""
        try:
            cursor = self.connection.cursor()
            cursor.execute("""
                SELECT ComponentID, ComponentName, RoutePattern, MenuID, 
                       ComponentType, IsActive, CreatedDate
                FROM tblSPA_Components
                ORDER BY ComponentName
            """)
            
            components = []
            for row in cursor.fetchall():
                components.append({
                    'id': row[0],
                    'name': row[1],
                    'route': row[2],
                    'menu_id': row[3],
                    'type': row[4],
                    'active': row[5],
                    'created': row[6]
                })
            
            return components
            
        except Exception as e:
            logger.error(f"Error listing components: {e}")
            return []

def main():
    parser = argparse.ArgumentParser(description='SPA Migration Tool')
    parser.add_argument('--action', choices=['migrate', 'migrate-all', 'register', 'list'], 
                       required=True, help='Action to perform')
    parser.add_argument('--component', help='Component name to migrate/register')
    parser.add_argument('--source-dir', default='./SPA_VU', help='Source directory path')
    parser.add_argument('--db-server', required=True, help='Database server')
    parser.add_argument('--db-name', required=True, help='Database name')
    parser.add_argument('--db-user', help='Database username (optional for Windows Auth)')
    parser.add_argument('--db-password', help='Database password')
    parser.add_argument('--route', help='Route pattern for manual registration')
    parser.add_argument('--menu', help='Menu ID for manual registration')
    parser.add_argument('--title', help='Component title for manual registration')
    parser.add_argument('--type', default='page', help='Component type (page, widget, modal)')
    
    args = parser.parse_args()
    
    # Initialize migrator
    migrator = SPAMigrator(args.db_server, args.db_name, args.db_user, args.db_password)
    
    if not migrator.connect_db():
        sys.exit(1)
    
    try:
        if args.action == 'migrate':
            if not args.component:
                logger.error("--component is required for migrate action")
                sys.exit(1)
            
            success = migrator.migrate_component(args.source_dir, args.component)
            if success:
                logger.info(f"✅ Successfully migrated component: {args.component}")
            else:
                logger.error(f"❌ Failed to migrate component: {args.component}")
                sys.exit(1)
        
        elif args.action == 'migrate-all':
            logger.info(f"Migrating all components from: {args.source_dir}")
            results = migrator.migrate_all_components(args.source_dir)
            
            logger.info(f"Migration completed: {results['success']} success, {results['failed']} failed")
            if results['errors']:
                for error in results['errors']:
                    logger.error(error)
        
        elif args.action == 'register':
            if not all([args.component, args.route]):
                logger.error("--component and --route are required for register action")
                sys.exit(1)
            
            title = args.title or args.component.replace('-', ' ').title()
            success = migrator.register_component_manual(
                args.component, title, args.route, args.menu, args.type
            )
            
            if success:
                logger.info(f"✅ Successfully registered component: {args.component}")
            else:
                logger.error(f"❌ Failed to register component: {args.component}")
                sys.exit(1)
        
        elif args.action == 'list':
            components = migrator.list_components()
            if components:
                print("\n📋 Components in database:")
                print("-" * 80)
                print(f"{'ID':<20} {'Name':<30} {'Route':<20} {'Type':<10}")
                print("-" * 80)
                for comp in components:
                    print(f"{comp['id']:<20} {comp['name']:<30} {comp['route']:<20} {comp['type']:<10}")
                print(f"\nTotal: {len(components)} components")
            else:
                print("No components found in database")
    
    finally:
        migrator.close_db()

if __name__ == '__main__':
    main()