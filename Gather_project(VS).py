import os
import re

# --- 1. CONFIGURATION (The Clean Filter) ---
IGNORE_DIRS = {
    'bin', 'obj', '.vs', '.git', 'Migrations', 'Properties'
}

# Only include files that contain YOUR logic
ALLOWED_EXTENSIONS = {'.cs', '.json', '.csproj'}

# Ignore specific heavy or non-code files
IGNORE_FILES = {
    'project_dump.txt', 'gather_code.py', 'appsettings.Development.json'
}

def gather_lean_project(output_file="lean_project_dump.txt", start_dir="."):
    total_files = 0
    visited_files = set()                 # Prevents dumping the same file twice
    processed_dirs = set()                # Prevents infinite directory loops
    dirs_to_process = [os.path.abspath(start_dir)] 
    
    # Regex to catch <ProjectReference Include="..\Path\To\Project.csproj" />
    ref_pattern = re.compile(r'<ProjectReference\s+Include="([^"]+)"')

    with open(output_file, "w", encoding="utf-8") as outfile:
        outfile.write("PROJECT ARCHITECTURE SNAPSHOT\n")
        outfile.write("=============================\n\n")

        # Process directories in our queue (which grows as we find references)
        while dirs_to_process:
            current_dir = dirs_to_process.pop(0)
            
            if current_dir in processed_dirs:
                continue
            processed_dirs.add(current_dir)

            for root, dirs, files in os.walk(current_dir):
                # Filter out ignored directories in-place
                dirs[:] = [d for d in dirs if d not in IGNORE_DIRS]
                
                for file in files:
                    if file in IGNORE_FILES:
                        continue
                        
                    file_path = os.path.abspath(os.path.join(root, file))
                    
                    # Prevent duplicate file entries if directory trees overlap
                    if file_path in visited_files:
                        continue
                        
                    _, ext = os.path.splitext(file)

                    if ext in ALLOWED_EXTENSIONS:
                        try:
                            with open(file_path, "r", encoding="utf-8") as infile:
                                content = infile.read()
                                
                            visited_files.add(file_path)
                            
                            # If it's a .csproj, mine it for external project references
                            if ext == '.csproj':
                                references = ref_pattern.findall(content)
                                for ref in references:
                                    # Normalize slashes for cross-platform safety
                                    safe_ref = ref.replace('\\', os.sep).replace('/', os.sep)
                                    ref_full_path = os.path.abspath(os.path.join(root, safe_ref))
                                    ref_dir = os.path.dirname(ref_full_path)
                                    
                                    # If the referenced project folder is new, add it to the queue
                                    if ref_dir not in processed_dirs and ref_dir not in dirs_to_process:
                                        dirs_to_process.append(ref_dir)
                                        print(f"🔗 Found external Project Reference, queueing: {ref_dir}")

                            outfile.write(f"\nFILE: {file_path}\n")
                            outfile.write("-" * 40 + "\n")
                            outfile.write(content + "\n")
                            total_files += 1
                            print(f"✅ Included: {file_path}")
                            
                        except Exception as e:
                            print(f"❌ Skipping {file_path}: {e}")

    print(f"\n🎉 DONE! {total_files} files gathered into {output_file}")

if __name__ == "__main__":
    gather_lean_project()