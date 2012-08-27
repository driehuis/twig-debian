Twig package for Debian
=======================

Packaging rules for Twig template library.

When a new version of Twig is released:

 1. Update debian/changelog to reflect changes.
 2. If necessary, change $DEBIAN_VERSION in build.sh (only if changing from -1).
 3. Run build.sh to download and build the package.
 4. Fix any lintian errors/warnings and re-build as necessary.
