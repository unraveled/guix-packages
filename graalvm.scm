(define-module (graalvm)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages base)
  #:use-module (gnu packages linux))

(use-modules
 (guix packages)
 (guix download)
 (guix gexp)
 (guix build-system gnu)
 ((guix licenses) :prefix license:)
 (gnu packages gawk)
 (guix utils)
 (guix git-download)
 (guix build-system cmake)
 (gnu packages)
 (gnu packages multiprecision)
 (gnu packages tls)
 (gnu packages compression)
 (gnu packages commencement)
 (gnu packages java)
 (gnu packages python)
 (gnu packages version-control)
 (gnu packages documentation)
 (gnu packages pkg-config)
 (gnu packages graphviz)
 (gnu packages libusb)
 (gnu packages boost)
 (gnu packages curl)
 (gnu packages llvm))

(define-public graalvm-native-image
  (package
    (name "graalvm-native-image")
    (version "22.3.1")
    (source (origin
              (method url-fetch)
	      (uri (string-append
		    "https://github.com/graalvm/graalvm-ce-builds"
		    "/releases/download/vm-" version
		    "/graalvm-ce-java11-linux-amd64-" version ".tar.gz"))
              (sha256
               (base32
                "1f6xkdnxn6xsm24sqw24rsca72wm7v6q96m23l5fng5ym0jpfm2m"))))
    (arguments
     (list
      ;; graal ships a jdk, the executables and .so files link each
      ;; other. the sdk itself should be the run path for most files,
      ;; so we should not use #:patchelf-plan or #:validate-runpath?
      #:validate-runpath? #f
      #:phases
      #~(modify-phases
	 %standard-phases
	 (add-before
	     'patchelf 'install-native-image
	   (lambda* (#:key inputs #:allow-other-keys)
	     (display inputs)
	     (invoke "patchelf" "--set-rpath"
		     (string-append
		      ":" (assoc-ref inputs "gcc-toolchain") "/lib"
		      ":" (assoc-ref inputs "zlib") "/lib")
		      "lib/installer/bin/gu")
	     (let ((interpreter
		    (car (find-files (assoc-ref inputs "libc")
				     "ld-linux.*\\.so"))))
	       (invoke "patchelf" "--set-interpreter" interpreter
		       "lib/installer/bin/gu"))		       
	     ;; "_" refers to the origin input of the native-image.jar
	     (invoke "lib/installer/bin/gu" "-L" "install"
		     (assoc-ref inputs "_"))	     
	     #f)))))
    (propagated-inputs
     ;; gcc is needed at runtime by graalvm
     (list gcc-toolchain-14))
    (inputs
     (list
      openjdk
      zlib
      `,(origin
	  (method url-fetch)
	  (uri
	   (string-append
	    "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-"
	    version "/native-image-installable-svm-java11-linux-amd64-"
	    version ".jar"))
	  (sha256
	   (base32
	    "1yb7kpbs7hrzlysvrqjzgfz678p1hbg6237jzb35zmwdaczav51n")))))
    (build-system binary-build-system)
    (home-page "https://www.graalvm.org/")
    (synopsis "An advanced JDK with ahead-of-time Native Image compilation")
    (description
     "GraalVM is a high-performance JDK designed to accelerate Java
application performance while consuming fewer resources. It provides
the Graal compiler, which can be used as a just-in-time compiler to
run Java applications on the HotSpot JVM or to ahead-of-time compile
them into native executables. Besides Java, it also provides runtimes
for JavaScript, Ruby, Python, and a several other popular languages
with polyglot capabilities.")
    (license license:asl2.0)))
