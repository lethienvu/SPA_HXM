#!/usr/bin/env python3
"""
Quick SPA Migration Script
=========================
Simplified version for quick testing and demo
"""

import os
import sys
from pathlib import Path

# Add current directory to path to import spa_migrator
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from spa_migrator import SPAMigrator
import logging

# Setup simple logging
logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s')
logger = logging.getLogger(__name__)

def quick_migrate():
    """Quick migration with default settings"""
    
    print("🚀 SPA Quick Migration Tool")
    print("=" * 50)
    
    # Get database info
    db_server = input("Database Server (localhost): ").strip() or "localhost"
    db_name = input("Database Name (Paradise_HPSF): ").strip() or "Paradise_HPSF"
    db_user = input("Database User (leave empty for Windows Auth): ").strip() or None
    db_password = input("Database Password: ").strip() or None if db_user else None
    
    print(f"\n📍 Connecting to: {db_server}/{db_name}")
    
    # Initialize migrator
    migrator = SPAMigrator(db_server, db_name, db_user, db_password)
    
    if not migrator.connect_db():
        print("❌ Database connection failed!")
        return False
    
    try:
        # Check current directory
        source_dir = "./SPA_VU"
        if not Path(source_dir).exists():
            print(f"❌ Source directory not found: {source_dir}")
            return False
        
        print(f"📂 Source directory: {source_dir}")
        
        # Ask what to do
        print("\nWhat would you like to do?")
        print("1. List existing components")
        print("2. Migrate all components")
        print("3. Migrate specific component")
        print("4. Register new component")
        
        choice = input("\nEnter choice (1-4): ").strip()
        
        if choice == "1":
            # List components
            print("\n📋 Existing components:")
            components = migrator.list_components()
            if components:
                print("-" * 70)
                print(f"{'ID':<20} {'Name':<30} {'Route':<20}")
                print("-" * 70)
                for comp in components:
                    print(f"{comp['id']:<20} {comp['name']:<30} {comp['route']:<20}")
                print(f"\nTotal: {len(components)} components")
            else:
                print("No components found")
        
        elif choice == "2":
            # Migrate all
            print(f"\n🔄 Migrating all components from {source_dir}...")
            results = migrator.migrate_all_components(source_dir)
            print(f"\n✅ Migration completed!")
            print(f"Success: {results['success']}, Failed: {results['failed']}")
            
            if results['errors']:
                print("\nErrors:")
                for error in results['errors']:
                    print(f"  ❌ {error}")
        
        elif choice == "3":
            # Migrate specific
            available_components = list(migrator.component_mapping.keys())
            print(f"\nAvailable components: {', '.join(available_components)}")
            component = input("Enter component name: ").strip()
            
            if component in available_components:
                print(f"\n🔄 Migrating component: {component}")
                if migrator.migrate_component(source_dir, component):
                    print(f"✅ Successfully migrated: {component}")
                else:
                    print(f"❌ Failed to migrate: {component}")
            else:
                print(f"❌ Unknown component: {component}")
        
        elif choice == "4":
            # Register new
            comp_id = input("Component ID: ").strip()
            comp_name = input("Component Name: ").strip()
            comp_route = input("Route (e.g., /new-page): ").strip()
            comp_menu = input("Menu ID (optional): ").strip() or None
            
            print(f"\n📝 Registering component: {comp_id}")
            if migrator.register_component_manual(comp_id, comp_name, comp_route, comp_menu):
                print(f"✅ Successfully registered: {comp_id}")
            else:
                print(f"❌ Failed to register: {comp_id}")
        
        else:
            print("❌ Invalid choice")
            return False
        
        return True
        
    finally:
        migrator.close_db()

if __name__ == "__main__":
    try:
        quick_migrate()
    except KeyboardInterrupt:
        print("\n\n👋 Migration cancelled by user")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        sys.exit(1)