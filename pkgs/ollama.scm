(define-module (ollama)
  #:use-module (gnu packages base)
  #:use-module (gnu packages commencement)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages package-management)
  #:use-module (gnu packages parallel)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) :prefix license:)
  #:use-module (guix packages)
  #:use-module (guix-science packages machine-learning)
  #:use-module (nonguix build-system binary)
  )

(define ollama-rocm-source
  (origin
    (method url-fetch)
    (uri
     (string-append
      "https://github.com/ollama/ollama/releases/download/v"
      "0.15.5"
      "/ollama-linux-amd64-rocm.tar.zst"))
    (sha256
     (base32
      "0yylpvh9kswj0c31lbjhb72x959w9m9n18755pchkk3r40qkq7qh"))))

(define-public ollama
  (package
    (name "ollama")
    (version "0.15.5")
    (source
     (origin
       (method url-fetch)
       (uri
	(string-append
	 "https://github.com/ollama/ollama/releases/download/v"
	 version
	 "/ollama-linux-amd64.tar.zst"))
       (sha256
	(base32
	 "09v89p6gz290aclxkdldncxmr8rjl1r0ppacwly183jlgd1awjff"))))
    (build-system binary-build-system)
    ;; we are giving oup on the patchelf plan for shared libraries
    ;; (too much). so LD_LIBRARY_PATH must be populared for dynamic
    ;; linking
    (native-search-paths
     (list (search-path-specification
	     (variable "LD_LIBRARY_PATH")
	     (files '("lib")))))
    (arguments
     (list
      #:phases
      #~(modify-phases %standard-phases
	  (add-after 'binary-unpack 'unpack-rocm
	    (lambda _
	      (format #t "Current dir: ~a~%" (getcwd))

	      (invoke "tar" "--zstd" "-xf"
		      #$ollama-rocm-source
		      "-C" ".."
		      "--wildcards" "lib/*")
	      (format #t "Lib after merge: ~a~%"
		      (find-files "../lib/ollama" ".*"))))
	  (add-before 'patchelf 'debug-patchelf-plan
	    (lambda _
	      (format #t "Found libraries: ~a~%"
		      (find-files "../lib" ".*\\.so(\\.[0-9]+)*$")
		      )))
	  (add-after 'binary-unpack 'chmod-to-allow-patchelf
	    (lambda _
	      (chmod "ollama" #o755))))
      #:strip-binaries? #f
      #:patchelf-plan
      #~(let ((libs (find-files "../lib" ".*\\.so(\\.[0-9]+)*$")))
	  `(("ollama" ("gcc-toolchain"))))
      #:validate-runpath? #f      ; lots of .so files really hard to patchelf link
      #:install-plan
      #~`(("ollama" "bin/ollama")
	  ("../lib" "lib")
	  )))
    (inputs (list
	     gcc-toolchain
	     xz
	     `(,zstd "lib")
	     bzip2))
    (native-inputs
     (list tar))
    (home-page "https://ollama.ai")
    (synopsis "Run large language models locally")
    (description
     "Ollama is a tool for running large language models locally. It bundles
model weights, configuration, and data into a single package. It
optimizes setup and configuration details, including GPU usage.")
    (license license:expat)))
