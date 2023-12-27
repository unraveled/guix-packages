(define-module (soju)			;
  #:use-module (guix build-system)
  #:use-module (guix build-system go)
  #:use-module (guix build-system gnu)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) :prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages golang-check)
  #:use-module (gnu packages linux)  
  #:use-module (gnu packages man)
  #:use-module (gnu packages syncthing))

(define-public soju
  (package
    (name "soju")
    (version "0.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sr.ht/~emersion/soju")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1a0mp8f5i1ajh67y6fasmzgca3w1ccaiz19sx87rflbyi1mrhdlz"))))
    (build-system go-build-system)
    (arguments
     `(#:import-path "git.sr.ht/~emersion/soju"
       #:go ,go-1.19
       #:install-source? #f
       #:phases (modify-phases %standard-phases
                  (replace 'build
                    (lambda* (#:key outputs #:allow-other-keys)
                      (with-directory-excursion "src/git.sr.ht/~emersion/soju"
                        (setenv "SYSCONFDIR"
                                (string-append (assoc-ref outputs "out")
                                               "/etc"))
                        (invoke "make"))))
                  (replace 'install
                    (lambda* (#:key outputs #:allow-other-keys)
                      (with-directory-excursion "src/git.sr.ht/~emersion/soju"
                        (let ((bin-dir (string-append (assoc-ref outputs "out")
                                                      "/bin"))
                              (conf-dir (string-append (assoc-ref outputs
                                                                  "out")
                                                       "/etc/soju")))
                          (install-file "soju" bin-dir)
                          (install-file "sojudb" bin-dir)
                          (install-file "sojuctl" bin-dir)
                          (substitute* "config.in"
                            ((".*")
                             ""))
                          (mkdir-p conf-dir)
                          (copy-file "config.in"
                                     (string-append conf-dir "/config"))))))
                  (add-before 'build 'set-flags
                    (lambda _
                      ;; Make sure CMake picks Clang as compiler
                      (begin
                        (setenv "CGO_LDFLAGS"
                         "-Wl,--unresolved-symbols=ignore-in-object-files") #t))))))
    (native-inputs `(("scdoc" ,scdoc)))
    (inputs `(("gcc-toolchain" ,gcc-toolchain)
              ("go-google-golang-org-protobuf" ,go-google-golang-org-protobuf)
              ("go" ,go-1.19)))
    (propagated-inputs
     `(("go-nhooyr-io-websocket" ,go-nhooyr-io-websocket)
       ("go-gopkg-in-irc-v4" ,go-gopkg-in-irc-v4)
       ("go-golang-org-x-time" ,go-golang-org-x-time)
       ("go-golang-org-x-crypto" ,go-golang-org-x-crypto)
       ("go-github-com-prometheus-client-golang"
        ,go-github-com-prometheus-client-golang-soju)
       ("go-github-com-pires-go-proxyproto"
        ,go-github-com-pires-go-proxyproto)
       ("go-github-com-msteinert-pam" ,go-github-com-msteinert-pam)
       ("go-github-com-mattn-go-sqlite3"
        ,go-github-com-mattn-go-sqlite3)
       ("go-github-com-lib-pq" ,go-github-com-lib-pq)
       ("go-github-com-emersion-go-sasl" ,go-github-com-emersion-go-sasl)
       ("go-github-com-sherclockholmes-webpush-go"
        ,go-github-com-sherclockholmes-webpush-go)
       ("go-git-sr-ht--sircmpwn-go-bare" ,go-git-sr-ht--sircmpwn-go-bare)
       ("go-git-sr-ht--emersion-go-sqlite3-fts5" ,go-git-sr-ht--emersion-go-sqlite3-fts5)
       ("go-git-sr-ht-emersion-go-scfg" ,go-git-sr-ht-emersion-go-scfg)))
    (home-page "https://git.sr.ht/~emersion/soju")
    (synopsis "User-friendly IRC bouncer") ;
    (description
     "soju connects to upstream IRC servers on behalf of the user to provide
extra functionality. soju supports many features
such as multiple users, numerous @@url{https://ircv3.net/,IRCv3} extensions,
chat history playback and detached channels.  It is well-suited for both small
and large deployments.")
    (license license:agpl3)))

(define-public go-nhooyr-io-websocket
  (package
    (name "go-nhooyr-io-websocket")
    (version "1.8.10")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/nhooyr/websocket")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1ig77m18sj8kx0f5xyi0vzvwc96cspsyk0d52dp5qph7vyc37lja"))))
    (build-system go-build-system)
    (arguments
     (list
      ;; #:go go-1.19
      #:tests? #f ;requires additional dependencies like `wasmbrowsertest`
      #:import-path "nhooyr.io/websocket"))
    (home-page "https://nhooyr.io/websocket")
    (synopsis "websocket")
    (description
     "Package websocket implements the
@@url{https://rfc-editor.org/rfc/rfc6455.html,RFC 6455} @code{WebSocket}
protocol.")
    (license license:isc)))

(define-public go-github-com-pires-go-proxyproto
  (package
    (name "go-github-com-pires-go-proxyproto")
    (version "0.7.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/pires/go-proxyproto")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1p18w555xp187fl807h1yd092cvs8jarp98pa76zl84rxlk4k2h4"))))
    (build-system go-build-system)
    (arguments
     (list
      #:go go-1.18
      #:import-path "github.com/pires/go-proxyproto"))
    (home-page "https://github.com/pires/go-proxyproto")
    (synopsis "go-proxyproto")
    (description
     "Package proxyproto implements Proxy Protocol (v1 and v2) parser and writer, as
per specification:
@@url{https://www.haproxy.org/download/2.3/doc/proxy-protocol.txt,https://www.haproxy.org/download/2.3/doc/proxy-protocol.txt}")
    (license license:asl2.0)))

(define-public go-github-com-msteinert-pam
  (package
    (name "go-github-com-msteinert-pam")
    (version "1.2.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/msteinert/pam")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1qnr0zxyxny85andq3cbj90clmz2609j8z9mp0zvdyxiwryfhyhj"))))
    (build-system go-build-system)
    (arguments
     (list
      #:go gccgo-12
      ;; tests don't work, they require special root set up
      #:tests? #f
      #:import-path "github.com/msteinert/pam"))
    (inputs `(("linux-pam" ,linux-pam)))
    (propagated-inputs `(("go-golang-org-x-term" ,go-golang-org-x-term)))
    (home-page "https://github.com/msteinert/pam")
    (synopsis "Go PAM")
    (description "Package pam provides a wrapper for the PAM application API.")
    (license license:bsd-2)))

(define-public go-github-com-sherclockholmes-webpush-go
  (package
    (name "go-github-com-sherclockholmes-webpush-go")
    (version "1.3.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/SherClockHolmes/webpush-go")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0qv16zvkd1c7q81v2ai8pfz590fxdrk4lfbgyymln0q7jn5wlvki"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/SherClockHolmes/webpush-go"))
    (propagated-inputs `(("go-golang-org-x-crypto" ,go-golang-org-x-crypto)
                         ("go-github-com-golang-jwt-jwt" ,go-github-com-golang-jwt-jwt)))
    (home-page "https://github.com/SherClockHolmes/webpush-go")
    (synopsis "webpush-go")
    (description "Web Push API Encryption with VAPID support.")
    (license license:expat)))

(define-public go-github-com-golang-jwt-jwt
  (package
    (name "go-github-com-golang-jwt-jwt")
    (version "3.2.2")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/golang-jwt/jwt")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0hq8wz11g6kddx9ab0icl5h3k4lrivk1ixappnr5db2ng2wjks9c"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "github.com/golang-jwt/jwt"))
    (home-page "https://github.com/golang-jwt/jwt")
    (synopsis "jwt-go")
    (description
     "Package jwt is a Go implementation of JSON Web Tokens:
@@url{http://self-issued.info/docs/draft-jones-json-web-token.html,http://self-issued.info/docs/draft-jones-json-web-token.html}")
    (license license:expat)))

(define-public go-git-sr-ht--sircmpwn-go-bare
  (package
    (name "go-git-sr-ht--sircmpwn-go-bare")
    (version "0.0.0-20210406120253-ab86bc2846d9")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sr.ht/~sircmpwn/go-bare")
             (commit (go-version->git-ref version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0zh36qppk8lscd8mysy0anm2vw5c74c10f4qvhd541wxm06di928"))))
    (build-system go-build-system)
    (arguments
     (list
      #:import-path "git.sr.ht/~sircmpwn/go-bare"))
    (propagated-inputs `(("go-github-com-stretchr-testify" ,go-github-com-stretchr-testify)
                         ("go-git-sr-ht--sircmpwn-getopt" ,go-git-sr-ht-sircmpwn-getopt)))
    (home-page "https://git.sr.ht/~sircmpwn/go-bare")
    (synopsis "An implementation of the BARE message format for Go")
    (description "An implementation of the BARE message format for Go.")
    (license license:asl2.0)))

(define-public go-git-sr-ht--emersion-go-sqlite3-fts5
  (package
    (name "go-git-sr-ht--emersion-go-sqlite3-fts5")
    (version "0.0.0-20230217131031-f2c8767594fc")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.sr.ht/~emersion/go-sqlite3-fts5")
             (commit "f2c8767594fc")))
       (file-name (git-file-name name version))
       (sha256
        (base32 "07wj4ypmfn8gmbg08bah3vrn6f2jbcfp47nlraw304rwpxflw05h"))))
    (build-system go-build-system)
    (arguments
     `(#:go ,go-1.18
       #:import-path "git.sr.ht/~emersion/go-sqlite3-fts5"
       #:phases (modify-phases %standard-phases
                  (add-before 'build 'set-flags
                    (lambda _
                      ;; Make sure CMake picks Clang as compiler
                      (begin
                        (setenv "CGO_LDFLAGS"
                         "-Wl,--unresolved-symbols=ignore-in-object-files") #t))))))
    (propagated-inputs `(("go-github-com-mattn-go-sqlite3" ,go-github-com-mattn-go-sqlite3)))
    (home-page "https://git.sr.ht/~emersion/go-sqlite3-fts5")
    (synopsis "go-sqlite3-fts5")
    (description "Standalone FTS5 extension for
@@url{https://github.com/mattn/go-sqlite3,go-sqlite3}.")
    (license license:expat)))

(define-public go-gopkg-in-irc-v4
  (package
    (name "go-gopkg-in-irc-v4")
    (version "4.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://gopkg.in/irc.v4")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1yr7m1vz7fj0jbmk8njg54nyc9hx4kv24k13sjc4zj5fyqljj0p2"))))
    (build-system go-build-system)
    (arguments
     (list
      #:tests? #f
      #:import-path "gopkg.in/irc.v4"
      #:unpack-path "gopkg.in/irc.v4"))
    (propagated-inputs `(("go-gopkg-in-yaml-v2" ,go-gopkg-in-yaml-v2)
                         ("go-golang-org-x-time" ,go-golang-org-x-time)
                         ("go-github-com-stretchr-testify" ,go-github-com-stretchr-testify)))
    (home-page "https://gopkg.in/irc.v4")
    (synopsis "go-irc")
    (description "nolint")
    (license license:expat)))

(define-public go-github-com-prometheus-client-golang-soju
  (package
    (name "go-github-com-prometheus-client-golang")
    (version "1.17.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/prometheus/client_golang")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1v8vdvi9wlpf18nxi62diysfnh9gc3c3cqq6hvx378snsvvl6n82"))))
    (build-system go-build-system)
    (arguments
     '(#:tests? #f
       #:import-path "github.com/prometheus/client_golang"
       #:phases (modify-phases %standard-phases
                  ;; Source-only package
                  (delete 'build))))
    (propagated-inputs (list go-github-com-beorn7-perks-quantile
                             go-github-com-golang-protobuf-proto
                             go-github-com-prometheus-client-model-soju
                             go-github-com-prometheus-common-soju
                             go-github-com-prometheus-procfs
                             go-github-com-cespare-xxhash))
    (synopsis "HTTP server and client tools for Prometheus")
    (description "This package @code{promhttp} provides HTTP client and
server tools for Prometheus metrics.")
    (home-page "https://github.com/prometheus/client_golang")
    (license license:asl2.0)))

(define-public go-github-com-prometheus-common-soju
  (package
    (name "go-github-com-prometheus-common-soju")
    (version "0.45.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/prometheus/common")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "006y6mlxglr2xzmdqxl5bwh899whfx1prcgjai7qhhs5ys5dspy5"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/prometheus/common"
       #:tests? #f
       #:phases (modify-phases %standard-phases
                  ;; Source-only package
                  (delete 'build))))
    (propagated-inputs (list go-github-com-golang-protobuf-proto
                        go-github-com-matttproud-golang-protobuf-extensions-pbutil-soju
                        go-github-com-prometheus-client-model-soju))
    (synopsis "Prometheus metrics")
    (description "This package provides tools for reading and writing
Prometheus metrics.")
    (home-page "https://github.com/prometheus/common")
    (license license:asl2.0)))

(define-public go-github-com-matttproud-golang-protobuf-extensions-pbutil-soju
  (package
    (name "go-github-com-matttproud-golang-protobuf-extensions-pbutil-soju")
    (version "2.0.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/matttproud/golang_protobuf_extensions")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "0jw4vjycwx0a82yvixmp25805krdyqd960y8lnyggllb6br0vh41"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path
       "github.com/matttproud/golang_protobuf_extensions/v2/pbutil"
       #:unpack-path "github.com/matttproud/golang_protobuf_extensions/v2"))
    (propagated-inputs (list go-github-com-golang-protobuf-proto
                             go-google-golang-org-protobuf))
    (synopsis "Streaming Protocol Buffers in Go")
    (description
     "This package provides various Protocol Buffer
extensions for the Go language, namely support for record length-delimited
message streaming.")
    (home-page "https://github.com/matttproud/golang_protobuf_extensions")
    (license license:asl2.0)))

(define-public go-github-com-prometheus-client-model-soju
  (package
    (name "go-github-com-prometheus-client-model-soju")
    (version "0.5.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/prometheus/client_model")
             (commit (string-append "v" version))))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1pl9i969jx5vkhm8vd5vb8yrifv37aw6h8mjg04820pw0ygfbigy"))))
    (build-system go-build-system)
    (arguments
     '(#:import-path "github.com/prometheus/client_model"
       #:tests? #f
       #:phases (modify-phases %standard-phases
                  ;; Source-only package
                  (delete 'build))))
    (propagated-inputs (list go-github-com-golang-protobuf-proto))
    (synopsis "Data model artifacts for Prometheus")
    (description "This package provides data model artifacts for Prometheus.")
    (home-page "https://github.com/prometheus/client_model")
    (license license:asl2.0)))
