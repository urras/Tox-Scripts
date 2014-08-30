#include <stdio.h>
#include <curl/curl.h>

/* TODO: somehow identify a new commit instead of running this periodically
 *       use libgit2 instead of calling git through system()
 *       build more stuff
 *       make it safer
 */

int get(char *argv[1]), tr(void), utox(void);

int main(int argc, char *argv[1])
{
    get(argv);
    FILE *commits;
    FILE *new;
    FILE *old;
    char c0[44], c1[44], c2[61];

    commits = fopen("commits", "r" );
    new     = fopen("new"    , "r+");
    old     = fopen("old"    , "r+");

    fseek(commits, 17, SEEK_SET);
    fgets(c0, sizeof(c0) + 1, commits);
    fseek(new, 0, SEEK_SET);
    fwrite(&c0, 1,  sizeof(c0), new);

    fseek(new, 0, SEEK_SET);
    fseek(old, 0, SEEK_SET);

    fgets(c1, sizeof(c1) + 1, new);
    fgets(c2, sizeof(c2) + 1, old);

    if(strcmp(c1, c2) != 0) {
        if(strcmp(argv[1],"tr") == 0)
            tr();
        if(strcmp(argv[1],"utox") == 0)
            utox();
        chdir("..");
        fseek(old, 0, SEEK_SET);
        fwrite(&c1, 1, sizeof(c1), old);
    }

    return 0;
}

int get(char *argv[1])
{
    CURL *curl;
    curl_global_init(CURL_GLOBAL_DEFAULT);
    curl = curl_easy_init();
    curl_easy_setopt(curl, CURLOPT_USERAGENT, "curl");

    if(strcmp(argv[1],"tr") == 0)
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.github.com/repos/Tox/Tox-Technical-Report/commits");
    if(strcmp(argv[1],"utox") == 0)
        curl_easy_setopt(curl, CURLOPT_URL, "https://api.github.com/repos/notsecure/utox/commits");

    FILE *file = fopen("commits", "w");
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, file);
    curl_easy_perform(curl);
    fclose(file);
    curl_easy_cleanup(curl);
    curl_global_cleanup();
    return 0;
}

int tr(void)
{
    chdir("./Tox-Technical-Report/");
    system("git pull");
    system("xelatex tox.tex");
    return 0;
}

int utox(void)
{
    chdir("./utox/");
    system("git pull");
    system("cc -o uTox.o *.c ./png/png.c -lX11 -lXrender -lXext -ltoxcore -ltoxav -ltoxdns -lopenal -lsodium -lopus -lvpx -lm -pthread -lresolv -ldl -lfontconfig -lfreetype -lv4lconvert -I/usr/include/freetype2 -ldbus-1");
    return 0;
}
