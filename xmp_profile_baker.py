#!/usr/bin/env python3
"""
XMP Profile Baker - Infrared Photography Tool
Embeds custom DCP profiles into XMP files for true universal compatibility
"""

import os
import re
import shutil
import tkinter as tk
from tkinter import ttk, messagebox
from pathlib import Path
import threading
import time

class XMPProfileBaker:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("XMP Profile Baker - Infrared Photography")
        self.root.geometry("600x400")
        self.root.resizable(False, False)
        
        # Set up paths
        self.script_dir = Path(__file__).parent
        self.source_dir = self.script_dir / "source_xmp_files"
        self.dcp_dir = self.script_dir / "dcp_profile"
        self.output_dir = self.script_dir / "output"
        
        self.setup_ui()
        self.check_initial_state()
        
    def setup_ui(self):
        """Create the GUI interface"""
        # Main frame
        main_frame = ttk.Frame(self.root, padding="20")
        main_frame.grid(row=0, column=0, sticky="nsew")
        
        # Title
        title_label = ttk.Label(
            main_frame, 
            text="XMP Profile Baker",
            font=("Arial", 16, "bold")
        )
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 10))
        
        subtitle_label = ttk.Label(
            main_frame,
            text="Embed your custom infrared DCP profile into XMP files",
            font=("Arial", 10)
        )
        subtitle_label.grid(row=1, column=0, columnspan=2, pady=(0, 20))
        
        # Status frame
        self.status_frame = ttk.LabelFrame(main_frame, text="Status", padding="15")
        self.status_frame.grid(row=2, column=0, columnspan=2, sticky="ew", pady=(0, 20))
        
        self.status_label = ttk.Label(
            self.status_frame,
            text="Checking for DCP profile...",
            font=("Arial", 10)
        )
        self.status_label.grid(row=0, column=0, sticky="w")
        
        # Instructions frame  
        self.instructions_frame = ttk.LabelFrame(main_frame, text="Instructions", padding="15")
        self.instructions_frame.grid(row=3, column=0, columnspan=2, sticky="ew", pady=(0, 20))
        
        self.instructions_label = ttk.Label(
            self.instructions_frame,
            text="",
            font=("Arial", 10),
            wraplength=500,
            justify="left"
        )
        self.instructions_label.grid(row=0, column=0, sticky="w")
        
        # Progress bar
        self.progress_frame = ttk.Frame(main_frame)
        self.progress_frame.grid(row=4, column=0, columnspan=2, sticky="ew", pady=(0, 20))
        
        self.progress = ttk.Progressbar(
            self.progress_frame, 
            mode='indeterminate'
        )
        self.progress.grid(row=0, column=0, sticky="ew", padx=(0, 10))
        
        self.progress_label = ttk.Label(self.progress_frame, text="")
        self.progress_label.grid(row=0, column=1)
        
        # Button frame
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=5, column=0, columnspan=2, pady=(0, 10))
        
        self.action_button = ttk.Button(
            button_frame,
            text="Proceed",
            command=self.handle_action,
            state="disabled"
        )
        self.action_button.grid(row=0, column=0, padx=(0, 10))
        
        self.refresh_button = ttk.Button(
            button_frame,
            text="Refresh",
            command=self.check_initial_state
        )
        self.refresh_button.grid(row=0, column=1, padx=(0, 10))
        
        self.exit_button = ttk.Button(
            button_frame,
            text="Exit",
            command=self.root.quit
        )
        self.exit_button.grid(row=0, column=2)
        
        # Configure grid weights
        main_frame.columnconfigure(0, weight=1)
        self.progress_frame.columnconfigure(0, weight=1)
        
    def check_initial_state(self):
        """Check if DCP profile exists and update UI accordingly"""
        dcp_files = list(self.dcp_dir.glob("*.dcp"))
        
        if dcp_files:
            profile_name = dcp_files[0].name
            self.status_label.config(
                text=f"✓ DCP Profile found: {profile_name}",
                foreground="green"
            )
            self.instructions_label.config(
                text="Ready to process XMP files! Click 'Proceed' to embed your DCP profile into the XMP files."
            )
            self.action_button.config(text="Process XMP Files", state="normal")
        else:
            self.status_label.config(
                text="⚠ No DCP profile found",
                foreground="orange"
            )
            instructions = (
                "1. Copy your custom infrared .dcp profile into the 'dcp_profile' folder\n\n"
                "2. Profile location: %APPDATA%\\Adobe\\CameraRaw\\CameraProfiles\\Imported\n\n"
                "3. Click 'Refresh' to check again, then 'Proceed' to continue"
            )
            self.instructions_label.config(text=instructions)
            self.action_button.config(text="Process XMP Files", state="disabled")
    
    def handle_action(self):
        """Handle the main action button click"""
        # Start processing in a separate thread
        self.action_button.config(state="disabled")
        self.refresh_button.config(state="disabled")
        
        processing_thread = threading.Thread(target=self.process_xmp_files)
        processing_thread.daemon = True
        processing_thread.start()
    
    def process_xmp_files(self):
        """Process XMP files by embedding the DCP profile reference"""
        try:
            self.update_progress("Starting processing...", True)
            
            # Get DCP profile
            dcp_files = list(self.dcp_dir.glob("*.dcp"))
            dcp_profile = dcp_files[0]
            profile_name = dcp_profile.stem  # Filename without extension
            
            self.update_progress(f"Using profile: {profile_name}", True)
            
            # Get source XMP files
            xmp_files = list(self.source_dir.glob("*.xmp"))
            
            if not xmp_files:
                self.update_progress("No XMP files found in source folder", False)
                messagebox.showerror(
                    "Error",
                    "No XMP files found in 'source_xmp_files' folder.\n\nPlease ensure the XMP files are in the correct location."
                )
                return
            
            self.update_progress(f"Found {len(xmp_files)} XMP files", True)
            
            # Clear output directory
            if self.output_dir.exists():
                shutil.rmtree(self.output_dir)
            self.output_dir.mkdir()
            
            processed_count = 0
            
            for xmp_file in xmp_files:
                self.update_progress(f"Processing: {xmp_file.name}", True)
                
                try:
                    # Read XMP content
                    with open(xmp_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Embed the DCP profile reference
                    updated_content = self.embed_dcp_profile(content, profile_name)
                    
                    # Write to output
                    output_path = self.output_dir / xmp_file.name
                    with open(output_path, 'w', encoding='utf-8') as f:
                        f.write(updated_content)
                    
                    processed_count += 1
                    
                except Exception as e:
                    self.update_progress(f"Error processing {xmp_file.name}: {str(e)}", False)
                    continue
            
            self.update_progress(f"✓ Complete! Processed {processed_count} files", False)
            
            # Show success message
            self.root.after(0, lambda: messagebox.showinfo(
                "Success!",
                f"Processing complete!\n\n"
                f"Processed: {processed_count} XMP files\n"
                f"Profile: {profile_name}\n\n"
                f"Output saved to 'output' folder.\n"
                f"Ready for distribution!"
            ))
            
        except Exception as e:
            self.update_progress(f"Error: {str(e)}", False)
            self.root.after(0, lambda: messagebox.showerror("Error", f"Processing failed:\n{str(e)}"))
        
        finally:
            # Re-enable buttons
            self.root.after(0, lambda: self.action_button.config(state="normal"))
            self.root.after(0, lambda: self.refresh_button.config(state="normal"))
    
    def embed_dcp_profile(self, content: str, profile_name: str) -> str:
        """Embed DCP profile reference into XMP content"""
        # Remove any existing camera profile references
        content = re.sub(r'\s*crs:CameraProfile="[^"]*"', '', content)
        content = re.sub(r'\s*crs:CameraModelRestriction="[^"]*"', '', content)
        content = re.sub(r'\s*crs:CameraProfileDigest="[^"]*"', '', content)
        
        # Find the description tag and add the camera profile reference
        # Look for the line with ProcessVersion to insert after it
        pattern = r'(\s*crs:ProcessVersion="[^"]*")'
        replacement = rf'\1\n   crs:CameraProfile="{profile_name}"'
        
        if re.search(pattern, content):
            content = re.sub(pattern, replacement, content)
        else:
            # Fallback: insert before HasSettings if ProcessVersion not found
            pattern = r'(\s*crs:HasSettings="[^"]*")'
            replacement = rf'   crs:CameraProfile="{profile_name}"\n\1'
            content = re.sub(pattern, replacement, content)
        
        return content
    
    def update_progress(self, message: str, show_progress: bool):
        """Update progress display"""
        def update():
            self.progress_label.config(text=message)
            if show_progress:
                self.progress.start(10)
            else:
                self.progress.stop()
        
        self.root.after(0, update)
        time.sleep(0.1)  # Small delay for visual feedback
    
    def run(self):
        """Start the GUI application"""
        self.root.mainloop()

if __name__ == "__main__":
    app = XMPProfileBaker()
    app.run()