#!/usr/bin/env python3
"""
XMP Profile Baker - Simple tool to embed camera profiles into XMP files
"""

import re
import shutil
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path
from threading import Thread
import platform
import os

class XMPProfileBaker:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("XMP Profile Baker")
        self.root.geometry("600x500")
        self.root.resizable(False, False)
        
        # Simple variables
        self.profile_method = tk.StringVar(value="rob_shea")
        self.rob_shea_temp = tk.StringVar(value="-50")
        self.manual_profile = tk.StringVar()
        self.xmp_profile_name = tk.StringVar()
        
        self.create_ui()
    
    def get_adobe_presets_dir(self):
        """Get Adobe Camera Raw ImportedSettings directory for current platform"""
        home = os.path.expanduser("~")
        if platform.system() == "Windows":
            adobe_dir = os.path.join(home, "AppData", "Roaming", "Adobe", "CameraRaw", "ImportedSettings")
        elif platform.system() == "Darwin":  # macOS
            adobe_dir = os.path.join(home, "Library", "Application Support", "Adobe", "CameraRaw", "ImportedSettings")
        else:  # Linux and other systems
            adobe_dir = os.path.join(home, ".adobe", "CameraRaw", "ImportedSettings")
        
        # Check if directory exists, fall back to home if not
        if not os.path.exists(adobe_dir):
            return home
        return adobe_dir
    
    def get_adobe_settings_dir(self):
        """Get Adobe Camera Raw Settings directory for current platform"""
        home = Path(os.path.expanduser("~"))
        if platform.system() == "Windows":
            return home / "AppData" / "Roaming" / "Adobe" / "CameraRaw" / "Settings"
        elif platform.system() == "Darwin":  # macOS
            return home / "Library" / "Application Support" / "Adobe" / "CameraRaw" / "Settings"
        else:  # Linux and other systems
            return home / ".adobe" / "CameraRaw" / "Settings"
        
    def create_ui(self):
        """Simple UI creation"""
        main = ttk.Frame(self.root, padding="20")
        main.pack(fill="both", expand=True)
        
        # Title
        ttk.Label(main, text="XMP Profile Baker", font=("Arial", 16, "bold")).pack(pady=(0,20))
        
        # Profile options
        options = ttk.LabelFrame(main, text="Choose Profile Name Source", padding="15")
        options.pack(fill="x", pady=(0,15))
        
        # Rob Shea option
        ttk.Radiobutton(options, text="Rob Shea's Profile Pack", 
                       variable=self.profile_method, value="rob_shea").pack(anchor="w")
        rob_frame = ttk.Frame(options)
        rob_frame.pack(fill="x", padx=(20,0), pady=(5,10))
        ttk.Radiobutton(rob_frame, text="Temp -50", variable=self.rob_shea_temp, value="-50").pack(side="left")
        ttk.Radiobutton(rob_frame, text="Temp -100", variable=self.rob_shea_temp, value="-100").pack(side="left", padx=(20,0))
        
        # XMP extract option
        ttk.Radiobutton(options, text="Extract from XMP file", 
                       variable=self.profile_method, value="xmp_extract").pack(anchor="w")
        xmp_frame = ttk.Frame(options)
        xmp_frame.pack(fill="x", padx=(20,0), pady=(5,10))
        ttk.Button(xmp_frame, text="Browse XMP...", command=self.browse_xmp).pack(side="left")
        self.xmp_status = ttk.Label(xmp_frame, text="No file selected")
        self.xmp_status.pack(side="left", padx=(10,0))
        
        # Manual option
        ttk.Radiobutton(options, text="Manual input", 
                       variable=self.profile_method, value="manual").pack(anchor="w")
        manual_frame = ttk.Frame(options)
        manual_frame.pack(fill="x", padx=(20,0), pady=(5,0))
        ttk.Label(manual_frame, text="Profile name:").pack(side="left")
        ttk.Entry(manual_frame, textvariable=self.manual_profile, width=30).pack(side="left", padx=(10,0))
        
        # Warning for manual input
        warning_frame = ttk.Frame(options)
        warning_frame.pack(fill="x", padx=(20,0), pady=(2,10))
        ttk.Label(warning_frame, text="Warning: Has to be exact, as seen in Lightroom Profile Selection.", 
                 foreground="red", font=("Arial", 9)).pack(anchor="w")
        
        # Status
        self.status = ttk.Label(main, text="Ready", foreground="green")
        self.status.pack(pady=20)
        
        # Buttons
        self.buttons = ttk.Frame(main)
        self.buttons.pack(pady=10)
        ttk.Button(self.buttons, text="Process Files", command=self.process).pack(side="left", padx=(0,10))
        
        # Adobe Settings button (initially hidden)
        self.adobe_button = ttk.Button(self.buttons, text="Write to Adobe Settings", command=self.write_to_adobe)
        
        self.exit_button = ttk.Button(self.buttons, text="Exit", command=self.root.quit)
        self.exit_button.pack(side="left")
        
        # Done message area (initially hidden)
        self.done_frame = ttk.Frame(main)
        self.done_frame.pack(fill="x", pady=(20,0))
        self.done_label = ttk.Label(self.done_frame, text="", foreground="green", font=("Arial", 10, "bold"))
        self.done_label.pack()
        
        # Bind updates
        self.profile_method.trace("w", self.update_status)
        self.rob_shea_temp.trace("w", self.update_status)
        self.manual_profile.trace("w", self.update_status)
        self.update_status()
    
    def update_status(self, *args):
        """Update status message"""
        method = self.profile_method.get()
        if method == "rob_shea":
            temp = self.rob_shea_temp.get()
            self.status.config(text=f"Ready: Infrared Temp {temp}", foreground="green")
        elif method == "xmp_extract":
            if self.xmp_profile_name.get():
                self.status.config(text=f"Ready: {self.xmp_profile_name.get()}", foreground="green")
            else:
                self.status.config(text="Select XMP file", foreground="orange")
        elif method == "manual":
            if self.manual_profile.get().strip():
                self.status.config(text=f"Ready: {self.manual_profile.get()}", foreground="green")
            else:
                self.status.config(text="Enter profile name", foreground="orange")
    
    def browse_xmp(self):
        """Browse and extract profile from XMP file"""
        # Start in Adobe Camera Raw imported settings directory
        adobe_presets_dir = self.get_adobe_presets_dir()
        
        file_path = filedialog.askopenfilename(
            title="Select XMP Preset File",
            initialdir=adobe_presets_dir,
            filetypes=[("XMP Files", "*.xmp"), ("All Files", "*.*")]
        )
        if not file_path:
            return
            
        try:
            with open(file_path, 'r') as f:
                content = f.read()
            match = re.search(r'crs:CameraProfile="([^"]*)"', content)
            if match:
                self.xmp_profile_name.set(match.group(1))
                self.xmp_status.config(text=f"Found: {match.group(1)}", foreground="green")
                self.profile_method.set("xmp_extract")
            else:
                messagebox.showerror("Error", "No CameraProfile found in XMP file")
        except Exception as e:
            messagebox.showerror("Error", f"Could not read file: {e}")
    
    def get_profile_name(self):
        """Get selected profile name"""
        method = self.profile_method.get()
        if method == "rob_shea":
            return f"Infrared Temp {self.rob_shea_temp.get()}"
        elif method == "xmp_extract":
            return self.xmp_profile_name.get()
        elif method == "manual":
            return self.manual_profile.get().strip()
        return None
    
    def sanitize_filename(self, name):
        """Sanitize profile name for use in filenames"""
        # Remove or replace forbidden characters for Windows filenames
        forbidden_chars = '<>:"/\\|?*'
        for char in forbidden_chars:
            name = name.replace(char, '_')
        # Replace spaces with underscores for cleaner filenames
        name = name.replace(' ', '_')
        # Remove multiple consecutive underscores
        while '__' in name:
            name = name.replace('__', '_')
        # Strip leading/trailing underscores
        name = name.strip('_')
        return name
    
    def create_filename_with_profile(self, original_name, profile_name):
        """Create new filename with profile name appended"""
        stem = Path(original_name).stem  # filename without extension
        ext = Path(original_name).suffix  # .xmp
        safe_profile = self.sanitize_filename(profile_name)
        return f"{stem}_{safe_profile}{ext}"
    
    def process(self):
        """Start processing"""
        profile_name = self.get_profile_name()
        if not profile_name:
            messagebox.showerror("Error", "Please select a profile source")
            return
        # Hide Adobe button and clear done message while processing
        self.adobe_button.pack_forget()
        self.done_label.config(text="")
        Thread(target=self.process_files, daemon=True).start()
    
    def process_files(self):
        """Process XMP files - simple version"""
        try:
            self.root.after(0, lambda: self.status.config(text="Processing...", foreground="blue"))
            
            # Get profile name and setup paths
            profile_name = self.get_profile_name()
            source_dir = Path(__file__).parent / "source_xmp_files"
            output_dir = Path(__file__).parent / "output"
            
            # Get XMP files
            xmp_files = list(source_dir.glob("*.xmp"))
            if not xmp_files:
                raise Exception("No XMP files found in source_xmp_files folder")
            
            # Create output directory
            if output_dir.exists():
                shutil.rmtree(output_dir)
            output_dir.mkdir()
            
            # Create subfolder for Rob Shea profiles
            if self.profile_method.get() == "rob_shea":
                temp = self.rob_shea_temp.get()
                output_dir = output_dir / f"Rob_Shea_Temp_{temp}"
                output_dir.mkdir()
            
            # Process each file
            count = 0
            for xmp_file in xmp_files:
                try:
                    with open(xmp_file, 'r') as f:
                        content = f.read()
                    
                    # Add profile to XMP
                    updated = self.add_profile_to_xmp(content, profile_name)
                    
                    # Create new filename with profile name
                    new_filename = self.create_filename_with_profile(xmp_file.name, profile_name)
                    
                    # Save updated file
                    with open(output_dir / new_filename, 'w') as f:
                        f.write(updated)
                    count += 1
                except Exception as e:
                    print(f"Error with {xmp_file.name}: {e}")
            
            # Show success
            self.root.after(0, lambda: self.show_done_message(
                f"Done! Processed {count} files with profile: {profile_name}"))
            
        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror("Error", str(e)))
        finally:
            self.root.after(0, lambda: self.status.config(text="Ready", foreground="green"))
    
    def show_done_message(self, message):
        """Show done message at bottom of window and reveal Adobe button"""
        self.done_label.config(text=message, foreground="green")
        # Show the Adobe Settings button after processing is complete
        self.adobe_button.pack(side="left", padx=(0,10), before=self.exit_button)
    
    def write_to_adobe(self):
        """Write output files to Adobe Camera Raw Settings directory"""
        profile_name = self.get_profile_name()
        if not profile_name:
            messagebox.showerror("Error", "Please select a profile source first")
            return
        Thread(target=self.write_to_adobe_thread, daemon=True).start()
    
    def write_to_adobe_thread(self):
        """Write files directly to Adobe Camera Raw Settings"""
        try:
            self.root.after(0, lambda: self.status.config(text="Writing to Adobe Settings...", foreground="blue"))
            
            # Get profile name and setup paths
            profile_name = self.get_profile_name()
            source_dir = Path(__file__).parent / "source_xmp_files"
            
            # Adobe Camera Raw Settings directory (cross-platform)
            adobe_settings_dir = self.get_adobe_settings_dir()
            
            # Create directory if it doesn't exist
            adobe_settings_dir.mkdir(parents=True, exist_ok=True)
            
            # Get XMP files
            xmp_files = list(source_dir.glob("*.xmp"))
            if not xmp_files:
                raise Exception("No XMP files found in source_xmp_files folder")
            
            # Process each file
            count = 0
            for xmp_file in xmp_files:
                try:
                    with open(xmp_file, 'r') as f:
                        content = f.read()
                    
                    # Add profile to XMP
                    updated = self.add_profile_to_xmp(content, profile_name)
                    
                    # Create new filename with profile name
                    new_filename = self.create_filename_with_profile(xmp_file.name, profile_name)
                    
                    # Save updated file to Adobe Settings
                    with open(adobe_settings_dir / new_filename, 'w') as f:
                        f.write(updated)
                    count += 1
                except Exception as e:
                    print(f"Error with {xmp_file.name}: {e}")
            
            # Show success
            self.root.after(0, lambda: self.show_done_message(
                f"Done! {count} files written to Adobe Camera Raw Settings with profile: {profile_name}"))
            
        except Exception as e:
            self.root.after(0, lambda: messagebox.showerror("Error", str(e)))
        finally:
            self.root.after(0, lambda: self.status.config(text="Ready", foreground="green"))
    
    def add_profile_to_xmp(self, content: str, profile_name: str) -> str:
        """Add camera profile to XMP content and update group name for Rob Shea profiles"""
        # Remove existing profile references
        content = re.sub(r'\s*crs:CameraProfile="[^"]*"', '', content)
        
        # Add new profile after ProcessVersion
        pattern = r'(\s*crs:ProcessVersion="[^"]*")'
        replacement = rf'\1\n   crs:CameraProfile="{profile_name}"'
        
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
        else:
            # Fallback: add before HasSettings
            pattern = r'(\s*crs:HasSettings="[^"]*")'
            replacement = rf'   crs:CameraProfile="{profile_name}"\n\1'
            content = re.sub(pattern, replacement, content)
        
        # Update group name for Rob Shea profiles
        if self.profile_method.get() == "rob_shea":
            temp = self.rob_shea_temp.get()
            ir_suffix = f" IR{temp}"
            
            # Find and update ONLY the group name in the <crs:Group> section
            group_pattern = r'(<crs:Group>\s*<rdf:Alt>\s*<rdf:li xml:lang="x-default">)([^<]*)(</rdf:li>\s*</rdf:Alt>\s*</crs:Group>)'
            
            def update_group_name(match):
                opening_tag = match.group(1)
                current_name = match.group(2)
                closing_tag = match.group(3)
                
                # Only add suffix if it's not already there
                if ir_suffix not in current_name:
                    new_name = current_name + ir_suffix
                else:
                    new_name = current_name
                
                return opening_tag + new_name + closing_tag
            
            content = re.sub(group_pattern, update_group_name, content, flags=re.DOTALL)
        
        return content
    
    def run(self):
        """Start the app"""
        self.root.mainloop()

if __name__ == "__main__":
    XMPProfileBaker().run()