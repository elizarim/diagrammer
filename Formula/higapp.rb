class Higapp < Formula
  desc "Generates image with hierarchy diagram using nested circles."
  homepage "https://github.com/elizarim/higapp"
  url "https://github.com/elizarim/higapp/releases/download/0.0.1/higapp-0.0.1.tar.gz"
  sha256 "567396b7259979f835ed74af29267ff63bfa5a308530272cdf4c0a3e965f14d9"

  depends_on xcode: ["15"]

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release"
    bin.install ".build/release/hig"
  end

  test do
    system "#{bin}/hig", "--help"
  end
end