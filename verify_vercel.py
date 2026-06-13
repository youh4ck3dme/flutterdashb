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
        
    # Check static Flutter SPA routes.
    routes = config.get('routes', [])
    if not routes:
        errors.append("Missing 'routes' configuration in vercel.json")
    else:
        filesystem_index = -1
        fallback_index = -1
        for i, r in enumerate(routes):
            src = r.get('src', '')
            if r.get('handle') == 'filesystem':
                filesystem_index = i
            elif src == '/(.*)' and r.get('dest') == '/index.html':
                fallback_index = i

        if filesystem_index == -1:
            errors.append("Could not find filesystem route before SPA fallback.")
        if fallback_index == -1:
            errors.append("Could not find SPA fallback route to /index.html.")
        if filesystem_index != -1 and fallback_index != -1 and filesystem_index > fallback_index:
            errors.append(
                f"Filesystem route (index {filesystem_index}) must be before SPA fallback "
                f"(index {fallback_index}) so JS/JSON assets are not served as HTML."
            )
                
    if errors:
        print("VERIFICATION FAILED:")
        for err in errors:
            print(f"  - {err}")
        sys.exit(1)
    else:
        print("VERIFICATION SUCCESSFUL: vercel.json serves Flutter static assets before SPA fallback.")

if __name__ == '__main__':
    verify_vercel()
