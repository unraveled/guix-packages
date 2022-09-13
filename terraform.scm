(define-module (terraform)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (nonguix build-system binary)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages linux))

(use-modules
 ((guix licenses) :prefix license:))

(define-public terraform
  (package
    (name "terraform")
    (version "1.2.9")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://releases.hashicorp.com/terraform/" version "/terraform_" version "_linux_amd64.zip"))
              (sha256
               (base32
                "1yzjcbis9syfz17sykg7j157dbdgm59ijbhj0dqw3nmd863c63qf"))))
    (arguments
     `(#:install-plan `(("." ("terraform") "bin/"))))
    (native-inputs
     `(("unzip" ,unzip)))
    (build-system binary-build-system)
    (home-page "https://www.terraform.io")
    (synopsis "A tool for building, changing, and versioning
infrastructure safely and efficiently.")
    (description "Terraform enables you to safely and predictably create, change, and
improve infrastructure. It is an open source tool that codifies APIs
into declarative configuration files that can be shared amongst team
members, treated as code, edited, reviewed, and versioned.")
    (license license:mpl2.0)))
