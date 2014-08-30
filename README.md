Tox / tox-scripts
===========

* <b>tox.sh</b><br>
Tox CLI installer, works on various distros and installs libsodium, [toxcore](https://github.com/irungentoo/toxcore/), toxic, venom and nurupo's Qt GUI<br>
To do: muTox, qTox, installer menu (python2 maybe?), improved argument handling

* <b>build.c</b><br>
This utility downloads a file of the form https://api.github.com/repos/USER/REPO/commits and compares the latest sha with the old file it has saved. If the sha matches, then there wasn't a new commit since last time and the program terminates, otherwise it updates the local repository to the current version and follows the instructions on the respective function to build whatever's relevant in the situation. Compilation is done as "cc build.c -lcurl". "./a.out tr" outputs the latest pdf, compiled from the LaTeX file on the repository. "./a.out utox" compiles uTox from source. The idea was to keep it modular, so adding new stuff to be built should be extremely simple: add a new function at the end of the file, containing the compilation instructions and add the necessary conditions on the main function. It is still pretty rough and there's quite some things to do, but I hope this serves as a good basis for interested parties.
