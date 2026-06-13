import json
import sys

def verify_vercel():
    vercel_path = 'vercel.json'
    
    try:
        with open(vercel_path, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Error reading or parsing vercel.json: {e}")
        sys.exit(1)
        
    errors = []
    
    # Check version
    if config.get('version') != 2:
        errors.append(f"Expected vercel.json version to be 2, found {config.get('version')}")
        
    # Check builds
    builds = config.get('builds', [])
    if not builds:
        errors.append("Missing 'builds' configuration in vercel.json")
    else:
        for b in builds:
            if b.get('src') == 'web/**' and b.get('use') != '@vercel/static-build':
                errors.append(f"Incorrect builder for web/**. Expected @vercel/static-build, found {b.get('use')}")
                
    # Check routes order
    routes = config.get('routes', [])
    if not routes:
        errors.append("Missing 'routes' configuration in vercel.json")
    else:
        api_index = -1
        fallback_index = -1
        for i, r in enumerate(routes):
            src = r.get('src', '')
            if '/api/' in src:
                api_index = i
            elif '/(.*)' in src:
                fallback_index = i
                
        if api_index != -1 and fallback_index != -1:
            if fallback_index < api_index:
                errors.append(f"SPA fallback route (index {fallback_index}) is placed before API proxy route (index {api_index}). API requests will be swallowed!")
        else:
            if api_index == -1:
                errors.append("Could not find API proxy route (/api/...) in vercel.json")
            if fallback_index == -1:
                errors.append("Could not find SPA fallback route (/(.*)) in vercel.json")
                
    if errors:
        print("VERIFICATION FAILED:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("VERIFICATION SUCCESSFUL: vercel.json is 100% correct and API routing is secure!")

if __name__ == '__main__':
    verify_vercel()
