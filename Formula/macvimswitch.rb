class Macvimswitch < Formula
  desc "Automatic input source switcher for Mac"
  homepage "https://github.com/jackiexiao/macvimswitch"
  version "0.3.0"  # 将在 GitHub Actions 中替换

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/jackiexiao/macvimswitch/releases/download/v#{version}/MacVimSwitch-arm64.zip"
      sha256 "93b882635da33d1fb703aca33be0913fe94432772078162bba8e2c514d4b7f7c"
    else
      url "https://github.com/jackiexiao/macvimswitch/releases/download/v#{version}/MacVimSwitch-x86_64.zip"
      sha256 "2473aac32e929f504f4b3287d1dd84ad0b7b79dc091d2131e492aa2dd76a0d84"
    end
  end

  depends_on :macos

  def install
    if OS.mac?
      # 首先检查文件是否存在
      unless File.exist?("MacVimSwitch.app")
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