# encoding: utf-8

module Yast
  class SquidClient < Client
    def main
      # testedfiles: Squid.ycp

      Yast.include self, "testsuite.rb"
      @READ = {
        "squid" => {
          "http_port"                 => [
            ["localhost:3128"],
            ["80", "transparent"]
          ],
          "acl"                       => [
            ["QUERY", "urlpath_regex", "cgi-bin", "\\?"],
            ["apache", "rep_header", "Server", "^Apache"],
            ["all", "src", "0.0.0.0/0.0.0.0"],
            ["manager", "proto", "cache_object"],
            ["localhost", "src", "127.0.0.1/255.255.255.255"],
            ["localhost_public", "src", "10.20.1.241/255.255.255.255"],
            ["to_localhost", "dst", "127.0.0.0/8"],
            ["SSL_ports", "port", " 443"],
            ["Safe_ports", "port", "80"],
            ["Safe_ports", "port", "21"],
            ["Safe_ports", "port", "443"],
            ["Safe_ports", "port", "70"],
            ["Safe_ports", "port", "210"],
            ["Safe_ports", "port", "1025-65535"],
            ["Safe_ports", "port", "280"],
            ["Safe_ports", "port", "488"],
            ["Safe_ports", "port", "591"],
            ["Safe_ports", "port", "777"],
            ["CONNECT", "method", "CONNECT"]
          ],
          "http_access"               => [
            ["allow", "manager", "localhost"],
            ["deny", "manager"],
            ["deny", "!Safe_ports"],
            ["deny", "CONNECT", "!SSL_ports"],
            ["allow", "localhost"],
            ["allow", "localhost_public"],
            ["deny", "all"]
          ],
          "refresh_pattern"           => [
            ["^ftp:", "1440", "20%", "10080"],
            ["-i", "^gopher:", "1440", "0%", "1440"],
            [".", "0", "20%", "4320"]
          ],
          "cache_dir"                 => [
            ["ufs", "/var/cache/squid", "100", "16", "256"]
          ],
          "cache_mem"                 => [["80", "MB"]],
          "cache_swap_low"            => [["90"]],
          "cache_swap_high"           => [["95"]],
          "maximum_object_size"       => [["4096", "KB"]],
          "minimum_object_size"       => [["0", "KB"]],
          "cache_replacement_policy"  => [["lru"]],
          "memory_replacement_policy" => [["heap", "GDSF"]],
          "access_log"                => [["/var/log/squid/access.log"]],
          "cache_log"                 => [["/var/log/squid/cache.log"]],
          "cache_store_log"           => [["/var/log/squid/store.log"]],
          "cache_swap_log"            => [["none"]],
          "connect_timeout"           => [["2", "minutes"]],
          "client_lifetime"           => [["1", "day"]],
          "error_directory"           => [["/usr/share/squid/errors/English"]],
          "cache_mgr"                 => [["webmaster"]],
          "ftp_passive"               => [["on"]],
          "no_cache"                  => [["deny", "QUERY"]]
        }
      }
      @READ = { "etc" => @READ }

      @WRITE = {}
      @EXECUTE = {
        "target" => {
          "bash_output" => {
            "exit"   => 0,
            "stdout" => "",
            "stderr" => ""
          }
        }
      }

      Yast.import "Squid"
      TESTSUITE_INIT([@READ, @WRITE, @EXECUTE], nil)

      Squid.Read

      DUMP("==================================================")
      DUMP("=====================  ACL  ======================")
      DUMP("==================================================")

      DUMP("")
      DUMP("GetACLs()")
      TEST(-> { Squid.GetACLs }, [], nil)

      DUMP("")
      DUMP("GetACL(0)")
      TEST(-> { Squid.GetACL(0) }, [], nil)
      DUMP("GetACL(2)")
      TEST(-> { Squid.GetACL(2) }, [], nil)
      DUMP("GetACL(100) - out of range")
      TEST(-> { Squid.GetACL(100) }, [], nil)

      DUMP("++++++++++++++++++++++++++++++++++++++++++++++++++")

      DUMP("")
      DUMP("AddACL(\"name\", \"type\", [\"list\", \"of\", \"options\"])")
      TEST(-> { Squid.AddACL("name", "type", ["list", "of", "options"]) }, [], nil)
      TEST(-> { Squid.GetACL(Ops.subtract(Builtins.size(Squid.GetACLs), 1)) }, [], nil)

      DUMP("")
      DUMP("ModifyACL(0, \"QUERY2\", \"urlpath_regex\", [\"cgi-bin \\? aaa\"])")
      TEST(-> { Squid.GetACL(0) }, [], nil)
      TEST(lambda do
        Squid.ModifyACL(0, "QUERY2", "urlpath_regex", ["cgi-bin \\? aaa"])
      end, [], nil)
      TEST(-> { Squid.GetACL(0) }, [], nil)
      TEST(lambda do
        Squid.ModifyACL(0, "QUERY", "urlpath_regex", ["cgi-bin \\?"])
      end, [], nil)

      DUMP("")
      DUMP("ModifyACL(100, \"A\", \"a\", [\"a\"]) - out of range")
      TEST(-> { Squid.GetACL(100) }, [], nil)
      TEST(-> { Squid.ModifyACL(100, "A", "a", ["a"]) }, [], nil)
      TEST(-> { Squid.GetACL(100) }, [], nil)

      DUMP("")
      DUMP("DelACL(1)")
      TEST(-> { Squid.GetACL(1) }, [], nil)
      TEST(-> { Squid.GetACL(2) }, [], nil)
      TEST(-> { Squid.DelACL(1) }, [], nil)
      TEST(-> { Squid.GetACL(1) }, [], nil)

      DUMP("")
      DUMP("DelACL(100) - out of range")
      TEST(-> { Squid.DelACL(100) }, [], nil)
      TEST(-> { Squid.GetACL(100) }, [], nil)
      TEST(-> { Squid.GetACL(0) }, [], nil)

      DUMP("++++++++++++++++++++++++++++++++++++++++++++++++++")

      DUMP("")
      DUMP("NumACLs(0)")
      TEST(-> { Squid.NumACLs(0) }, [], nil)
      DUMP("NumACLs(10)")
      TEST(-> { Squid.NumACLs(10) }, [], nil)

      DUMP("")
      DUMP("ACLIsUsedBy(0) - QUERY")
      TEST(-> { Squid.ACLIsUsedBy(0) }, [@READ, @WRITE, @EXECUTE], nil)
      DUMP("ACLIsUsedBy(1)")
      TEST(-> { Squid.ACLIsUsedBy(1) }, [@READ, @WRITE, @EXECUTE], nil)

      DUMP("==================================================")
      DUMP("================  HTTP_ACCESS  ===================")
      DUMP("==================================================")

      DUMP("")
      DUMP("GetHttpAccesses()")
      TEST(-> { Squid.GetHttpAccesses }, [], nil)

      DUMP("")
      DUMP("GetHttpAccess(0)")
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)
      DUMP("GetHttpAccess(2)")
      TEST(-> { Squid.GetHttpAccess(2) }, [], nil)
      DUMP("GetHttpAccess(100) - out of range")
      TEST(-> { Squid.GetHttpAccess(100) }, [], nil)

      DUMP("++++++++++++++++++++++++++++++++++++++++++++++++++")

      DUMP("")
      DUMP("AddHttpAccess(true, [\"list\", \"of\", \"acls\"])")
      TEST(-> { Squid.AddHttpAccess(true, ["list", "of", "acls"]) }, [], nil)
      TEST(lambda do
        Squid.GetHttpAccess(
          Ops.subtract(Builtins.size(Squid.GetHttpAccesses), 1)
        )
      end, [], nil)

      DUMP("")
      DUMP("ModifyHttpAccess(0, false, [\"manager\", \"locahost\"])")
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)
      TEST(-> { Squid.ModifyHttpAccess(0, false, ["manager", "localhost"]) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)
      TEST(-> { Squid.ModifyHttpAccess(0, true, ["manager", "localhost"]) }, [], nil)

      DUMP("")
      DUMP("ModifyHttpAccess(100, true, [\"a\"]) - out of range")
      TEST(-> { Squid.GetHttpAccess(100) }, [], nil)
      TEST(-> { Squid.ModifyHttpAccess(100, true, ["a"]) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(100) }, [], nil)

      DUMP("")
      DUMP("DelHttpAccess(1)")
      TEST(-> { Squid.GetHttpAccess(1) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(2) }, [], nil)
      TEST(-> { Squid.DelHttpAccess(1) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(1) }, [], nil)

      DUMP("")
      DUMP("MoveHttpAccess(0,1)")
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(1) }, [], nil)
      TEST(-> { Squid.MoveHttpAccess(0, 1) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(1) }, [], nil)

      DUMP("")
      DUMP("DelHttpAccess(100) - out of range")
      TEST(-> { Squid.DelHttpAccess(100) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(100) }, [], nil)
      TEST(-> { Squid.GetHttpAccess(0) }, [], nil)

      DUMP("==================================================")
      DUMP("=================   SETTINGS  ====================")
      DUMP("==================================================")

      DUMP("")
      DUMP("GetSettings()")
      TEST(-> { Squid.GetSettings }, [], nil)

      DUMP("")
      DUMP("GetSetting(\"cache_dir\")")
      TEST(-> { Squid.GetSetting("cache_dir") }, [], nil)

      DUMP("")
      DUMP(
        "SetSetting(\"cache_dir\", [\"uufs\", \"/var/\", \"10\", \"10\", \"10\"])"
      )
      TEST(lambda do
        Squid.SetSetting("cache_dir", ["uufs", "/var/", "10", "10", "10"])
      end, [], nil)
      TEST(-> { Squid.GetSetting("cache_dir") }, [], nil)

      DUMP("==================================================")
      DUMP("==============  REFRESH_PATTERNS  ================")
      DUMP("==================================================")
      DUMP("")
      DUMP("GetRefreshPatterns()")
      TEST(-> { Squid.GetRefreshPatterns }, [], nil)

      DUMP("")
      DUMP("GetRefreshPattern(0)")
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)
      DUMP("GetRefreshPattern(2)")
      TEST(-> { Squid.GetRefreshPattern(2) }, [], nil)
      DUMP("GetRefreshPattern(100) - out of range")
      TEST(-> { Squid.GetRefreshPattern(100) }, [], nil)

      DUMP("++++++++++++++++++++++++++++++++++++++++++++++++++")

      DUMP("")
      DUMP("AddRefreshPattern(\"regexp\", \"100\", \"100\", \"100\", false)")
      TEST(lambda do
        Squid.AddRefreshPattern("regexp", "100", "100", "100", false)
      end, [], nil)
      TEST(lambda do
        Squid.GetRefreshPattern(
          Ops.subtract(Builtins.size(Squid.GetRefreshPatterns), 1)
        )
      end, [], nil)

      DUMP("")
      DUMP(
        "ModifyRefreshPattern(0, \"regexp\",  \"100\", \"100\", \"100\", false)"
      )
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)
      TEST(lambda do
        Squid.ModifyRefreshPattern(0, "regexp", "100", "100", "100", false)
      end, [], nil)
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)

      DUMP("")
      DUMP(
        "ModifyRefreshPattern(100, \"regexp\",  \"100\", \"100\", \"100\", false)"
      )
      TEST(-> { Squid.GetRefreshPattern(100) }, [], nil)
      TEST(lambda do
        Squid.ModifyRefreshPattern(100, "regexp", "100", "100", "100", false)
      end, [], nil)
      TEST(-> { Squid.GetRefreshPattern(100) }, [], nil)

      DUMP("")
      DUMP("DelRefreshPattern(1)")
      TEST(-> { Squid.GetRefreshPattern(1) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(2) }, [], nil)
      TEST(-> { Squid.DelRefreshPattern(1) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(1) }, [], nil)

      DUMP("")
      DUMP("MoveRefreshPattern(0,1)")
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(1) }, [], nil)
      TEST(-> { Squid.MoveRefreshPattern(0, 1) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(1) }, [], nil)

      DUMP("")
      DUMP("DelRefreshPattern(100) - out of range")
      TEST(-> { Squid.DelRefreshPattern(100) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(100) }, [], nil)
      TEST(-> { Squid.GetRefreshPattern(0) }, [], nil)

      DUMP("==================================================")
      DUMP("=================  HTTP_PORT  ====================")
      DUMP("==================================================")

      DUMP("")
      DUMP("GetHttpPorts()")
      TEST(-> { Squid.GetHttpPorts }, [], nil)

      DUMP("")
      DUMP("GetHttpPort(0)")
      TEST(-> { Squid.GetHttpPort(0) }, [], nil)
      DUMP("GetHttpPort(2)")
      TEST(-> { Squid.GetHttpPort(2) }, [], nil)
      DUMP("GetHttpPort(100) - out of range")
      TEST(-> { Squid.GetHttpPort(100) }, [], nil)

      DUMP("++++++++++++++++++++++++++++++++++++++++++++++++++")

      DUMP("")
      DUMP("AddHttpPort(\"host\", \"port\", true)")
      TEST(-> { Squid.AddHttpPort("host", "port", true) }, [], nil)
      TEST(lambda do
        Squid.GetHttpPort(Ops.subtract(Builtins.size(Squid.GetHttpPorts), 1))
      end, [], nil)

      DUMP("")
      DUMP("ModifyHttpPort(0, \"host\", \"port\", true)")
      TEST(-> { Squid.GetHttpPort(0) }, [], nil)
      TEST(-> { Squid.ModifyHttpPort(0, "host", "port", true) }, [], nil)
      TEST(-> { Squid.GetHttpPort(0) }, [], nil)

      DUMP("")
      DUMP("ModifyHttpPort(100, \"host\", \"port\", true)")
      TEST(-> { Squid.GetHttpPort(100) }, [], nil)
      TEST(-> { Squid.ModifyHttpPort(100, "host", "port", true) }, [], nil)
      TEST(-> { Squid.GetHttpPort(100) }, [], nil)

      DUMP("")
      DUMP("DelHttpPort(1)")
      TEST(-> { Squid.GetHttpPort(1) }, [], nil)
      TEST(-> { Squid.GetHttpPort(2) }, [], nil)
      TEST(-> { Squid.DelHttpPort(1) }, [], nil)
      TEST(-> { Squid.GetHttpPort(1) }, [], nil)

      DUMP("")
      DUMP("DelHttpPort(100) - out of range")
      TEST(-> { Squid.DelHttpPort(100) }, [], nil)
      TEST(-> { Squid.GetHttpPort(100) }, [], nil)
      TEST(-> { Squid.GetHttpPort(0) }, [], nil)

      nil
    end
  end
end

Yast::SquidClient.new.main
