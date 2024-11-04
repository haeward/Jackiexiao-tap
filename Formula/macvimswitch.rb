class Macvimswitch < Formula
  desc "Automatic input source switcher for Mac"
  homepage "https://github.com/jackiexiao/macvimswitch"
  version "0.5.0"  # 将在 GitHub Actions 中替换

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/jackiexiao/macvimswitch/releases/download/v#{version}/MacVimSwitch-arm64.zip"
      sha256 "69746ffe94ca7f244b4661aea1c1ce41d4bd162a5a82c92bcd8aa7ad51ad6d09"
    else
      url "https://github.com/jackiexiao/macvimswitch/releases/download/v#{version}/MacVimSwitch-x86_64.zip"
      sha256 "1bfc75d7635d71c8ff68fbee68898ad0d24c99d919039abeee11ce2bea3a36cb"
    end
  end

  depends_on :macos

  def install
    if OS.mac?
      # 解压 zip 文件
      system "unzip", Dir["*.zip"].first
      
      # 输出解压后的内容
      ohai "Contents after unzip:"
      system "ls", "-la"
      
      # 添加调试信息
      ohai "Current directory contents:"
      system "ls", "-la"
      
      # 解压后验证文件结构
      ohai "Zip contents:"
      system "unzip", "-l", Dir["*.zip"].first
      
      # 首先检查文件是否存在
      unless File.exist?("MacVimSwitch.app")
        ohai "Directory contents after checking for app:"
        system "ls", "-la"
        ohai "Trying to find app recursively:"
        system "find", ".", "-name", "MacVimSwitch.app"
        odie "MacVimSwitch.app not found in the downloaded package"
      end
      
      # 安装到 prefix 目录
      prefix.install "MacVimSwitch.app"
      
      # 验证安装
      app_path = prefix/"MacVimSwitch.app"
      unless File.exist?(app_path)
        odie "Failed to install MacVimSwitch.app"
      end
      
      # 验证可执行文件
      bin_path = app_path/"Contents/MacOS/macvimswitch"
      unless File.exist?(bin_path)
        odie "Executable not found in app bundle"
      end
      
      # 创建命令行工具的符号链接
      bin.install_symlink bin_path => "macvimswitch"
      
      # 创建应用程序链接
      Applications.install_symlink app_path
    end
  end

  def post_install
    # 添加到登录项，使用实际安装路径
    system "osascript", "-e", <<~APPLESCRIPT
      tell application "System Events"
        make new login item at end with properties {path:"#{prefix}/MacVimSwitch.app", hidden:false}
      end tell
    APPLESCRIPT
  end
  
  def caveats
    <<~EOS
      MacVimSwitch has been installed to #{prefix}/MacVimSwitch.app
      A symlink has been created in /Applications
      
      Important:
      1. You need to grant Accessibility permissions to the app
      2. Go to System Preferences -> Security & Privacy -> Privacy -> Accessibility
      3. Add and enable MacVimSwitch.app
      
      To start MacVimSwitch now, run:
        open #{prefix}/MacVimSwitch.app
      
      To stop MacVimSwitch:
      - Click the keyboard icon in the menu bar
      - Select "Quit"
      
      You can enable/disable launch at login from the menu bar icon.
      
      Or use command line:
        pkill macvimswitch
    EOS
  end

  test do
    assert_predicate prefix/"MacVimSwitch.app/Contents/MacOS/macvimswitch", :exist?
  end
end 