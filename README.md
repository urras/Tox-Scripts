Tox / tox-scripts
===========

* <b>tox.sh</b><br>
Tox CLI installer, works on various distros and installs libsodium, [toxcore](https://github.com/irungentoo/toxcore/), toxic, venom and nurupo's Qt GUI<br>
<b>To do:</b> muTox, qTox, installer menu (python2 maybe?), improved argument handling, check if latest version is already installed (<i>see build.c</i>).<br>
Some user-friendliness:<pre>
    wget -O tox.sh waa.ai/iqt && chmod +x ./tox.sh && ./tox.sh
        #fetch latest script and install everything
    ./tox.sh -sl        #to skip libsodium (they don't update that often)
    ./tox.sh -sd        #to skip libsodium and all the other dependencies</pre>

* <b>build.c</b><br>
This utility downloads a file of the form <code>https://api.github.com/repos/USER/REPO/commits</code> and compares the latest sha with the old file it has saved. If the sha matches, then there wasn't a new commit since last time and the program terminates, otherwise it updates the local repository to the current version and follows the instructions on the respective function to build whatever's relevant in the situation. Compilation is done as "<code>cc build.c -lcurl</code>". "<code>./a.out tr</code>" outputs the latest pdf, compiled from the LaTeX file on the repository. "<code>./a.out utox</code>" compiles uTox from source. The idea was to keep it modular, so adding new stuff to be built should be extremely simple: add a new function at the end of the file, containing the compilation instructions and add the necessary conditions on the main function. It is still pretty rough and there's quite some things to do, but I hope this serves as a good basis for interested parties.
