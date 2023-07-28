(define-module (clojure)
         #:use-module ((guix licenses) #:prefix license:)
         #:use-module (guix packages)
         #:use-module (guix download)
         #:use-module (guix utils)
         #:use-module (gnu packages gcc)
         #:use-module (gnu packages compression)
         #:use-module (nonguix build-system binary))

(define-public babashka
  (package
    (name "babashka")
    (version "1.3.176")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/borkdude/babashka/releases/download/v" version "/babashka-" version "-linux-amd64.tar.gz"))
              (sha256
               (base32
                "0lkjr8hp0nqp7iyr4gc443xfs8hy1i5map678iarmnd9iv16dj26"))))
    (build-system binary-build-system)
    (supported-systems '("x86_64-linux" "i686-linux"))
    (arguments
     `(#:patchelf-plan
       `(("bb" ("libc" "zlib" "libstdc++")))
       #:install-plan
       `(("." ("bb") "bin/"))))
    (inputs
      `(("libstdc++" ,(make-libstdc++ gcc))
        ("zlib" ,zlib)))
    (native-inputs
      `(("unzip" ,unzip)))
    (synopsis "A Clojure babushka for the grey areas of Bash")
    (description
      "The main idea behind babashka is to leverage Clojure in places
where you would be using bash otherwise.")
    (home-page "https://github.com/borkdude/babashka")
    (license license:epl1.0)))
