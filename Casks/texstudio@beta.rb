cask "texstudio@beta" do
  arch arm: "-m1"

  version "4.9.8rc1"
  sha256 arm:   "a10bafe00d47a64db5a25fe0c0bd0317e1ccfc2d84acaf3388ed34a4f123dc3b",
         intel: "4b598d4b5af805350ce1a9dc66f259175446472b72a765a1b7dd843f04b6e381"

  url "https://github.com/texstudio-org/texstudio/releases/download/#{version}/texstudio-#{version}-osx#{arch}.zip"
  name "TeXstudio"
  desc "Fully featured LaTeX editor, beta version"
  homepage "https://texstudio.org/"

  livecheck do
    # based on https://docs.brew.sh/Brew-Livecheck#githubreleases-strategy-block
    # see also livecheck stanzas in other casks recorded in the
    # `github_prerelease_allowlist.json` in Homebrew/cask tap
    # https://github.com/Homebrew/homebrew-cask/blob/main/audit_exceptions/github_prerelease_allowlist.json
    url :url
    regex(/
      ^v?(\d+(?:\.\d+)+            # version number
      (?:(?:alpha|beta|rc)\d+)?)$  # optional pre-release identifier
    /ix)
    strategy :github_releases do |json, regex|
      json.map do |release|
        # accept non-draft prereleases only
        next if release["draft"] || !release["prerelease"]

        match = release["tag_name"]&.match(regex)
        next if match.blank?

        match[1]
      end
    end
  end

  # Although the app names differ, they share the same Bundle ID `texstudio`, so strictly speaking,
  # they still conflict with each other.
  conflicts_with cask: [
    "Homebrew/cask/texstudio",
    "texstudio-org/texstudio/texstudio",
    "texstudio-org/texstudio/texstudio@all",
  ]
  depends_on macos: :ventura

  # It's NOT recommended to rename the target only for removing version numbers.
  # https://docs.brew.sh/Cask-Cookbook#target-should-only-be-used-in-select-cases
  app "texstudio-#{version}-osx#{arch}.app"

  # learnt from https://github.com/Homebrew/homebrew-cask/blob/03a0edb4616198f6f64b285dbf842bc3b73a7f31/Casks/p/parallels.rb#L36-L41
  # and https://github.com/Homebrew/homebrew-cask/commit/adfc07a7bc28a32037851be4d7a0bd4f8b239565
  postflight_steps do
    run "xattr",
        args: ["-dr", "com.apple.quarantine", "{{appdir}}/texstudio-{{version}}-osx{{arch}}.app"]
  end

  # Check Bundle ID with `brew list-running-app-ids`. Locally cloned cask tap needed, run
  # `brew tap --force homebrew/cask`.
  # https://docs.brew.sh/Cask-Cookbook#uninstall-quit
  uninstall quit: "texstudio"

  zap trash: [
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/texstudio.sfl*",
    "~/Library/Preferences/texstudio.plist",
    "~/Library/Saved Application State/texstudio.savedState",
  ]
end
