(define-module (kubernetes)
  #:use-module (gnu packages base)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages golang)
  #:use-module (gnu packages node)
  #:use-module (gnu packages perl)
  #:use-module (gnu packages python)
  #:use-module (gnu packages ruby)
  #:use-module (gnu packages version-control)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix download)
  #:use-module (guix build-system go)
  #:use-module ((guix licenses) #:prefix license:))

(define-public go-k8s-io-kubernetes
  (package
   (name "go-k8s-io-kubernetes")
   (version "1.23.6")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/kubernetes/kubernetes")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0xvwdgypyhaszkrn8fa3sdlmy5fy1lx7hmh2s5n88fxkc2b950kr"))))
   (build-system go-build-system)
   (arguments
    `(#:import-path "k8s.io/kubernetes/kubernetes"
      #:tests? #f
      #:phases (modify-phases %standard-phases
                              ;; Source-only package
                              (delete 'build))))
   (home-page "https://github.com/kubernetes/kubernetes")
   (synopsis "Kubernetes")
   (description
    "Kubernetes is an open source system for managing
@url{https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/,containerized
applications} across multiple hosts; providing basic mechanisms for
deployment, maintenance, and scaling of applications.")
   (license license:asl2.0)))

(define-public kubectl
  (package
   (inherit go-k8s-io-kubernetes)
   (name "kubectl")
   (native-inputs `(("bash" ,bash)))
   (arguments
    '(#:unpack-path "k8s.io/kubernetes"
      #:import-path "k8s.io/kubernetes/cmd/kubectl"
      #:install-source? #f
      #:build-flags (list (string-append
                           "-ldflags=-s -w "
                           "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitCommit=ad3338546da947756e8a88aa6822e9c11e7eac22' "
                           "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitTreeState=clean' "
                           "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitVersion=v1.23.6' "
                           "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitMajor=1' "
                           "-X 'k8s.io/kubernetes/vendor/k8s.io/component-base/version.gitMinor=23'"))
      #:phases (modify-phases %standard-phases
                              (delete 'install-license-files))))))

(define-public k9s
  (package
   (name "k9s")
   (version "0.26.7")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/derailed/k9s")
           (commit (string-append "v" version))))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0g2p6gs6s22sxgxlbmpbzjgfzk29hzs2c5767yajl69hj9059j2f"))))
   (build-system go-build-system)
   (arguments
    `(#:tests? #f
      #:unpack-path "github.com/derailed/k9s"
      #:import-path "github.com/derailed/k9s"
      #:build-flags (list (string-append
                           "-ldflags=-s -w "
                           "-X 'github.com/derailed/k9s/cmd.version=v0.26.7' "
                           "-X 'github.com/derailed/k9s/cmd.commit=37569b8772eee3ae29c3a3a1eabb34f459f0b595' "
                           "-X 'github.com/derailed/k9s/cmd.date=v0.26.7' "))))
   (home-page "https://github.com/kubernetes/kubernetes")
   (synopsis "K9s provides a terminal UI to interact with your Kubernetes.")
   (description
    "Make it easier to navigate, observe and manage your applications in
the wild. K9s continually watches Kubernetes for changes and offers
subsequent commands to interact with your observed resources.")
   (license license:asl2.0)))
