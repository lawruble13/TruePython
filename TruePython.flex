%{
  #include <stdio.h>
  #include <string.h>
  #include <stdarg.h>

  #define BUFLEN 100

  int phys_lineno = 0;
  int log_lineno = 0;
  unsigned char utf8_buf[BUFLEN+1];
  int utf8_buf_len;

  void addNewIdentifier();
  void getReferencedIdentifier();
  void setIdentifierReference();
  int getHissIndex();
  char getHissIDCharacter();
  char getHissStringCharacter();
  void print_escaped_string();
  void error(int exit_code, const char* error_fmt, ...);
%}
NEWLINE \r\n?
RESERVED ([hH][hH]?[iI][sS])|([hH][iI][iI][sS])|([hH][iI][sS][sS][sS]?)|hiiss
%x ID
%x BINARY
%x STRING
%x INTEGER
%x FLOAT
%x EMBED
%x COMMENT
%option stack
%%
<INITIAL>{
  his {error(1, "Encountered unmatched end on line %d.\n", phys_lineno);}
  hiS[ \t] {
    utf8_buf_len = 0;
    yy_push_state(EMBED);
  }
  hIs[ \t]* {
    utf8_buf_len = 0;
    yy_push_state(ID);
  }
  hIS[ \t]* {
    utf8_buf_len = 0;
    printf("\"");
    yy_push_state(STRING);
  }
  His[ \t]* {
    utf8_buf_len = 0;
    yy_push_state(INTEGER);
  }
  HiS[ \t]* {
    utf8_buf_len = 0;
    yy_push_state(FLOAT);
  }
  HIs[ \t]* {
    utf8_buf_len = 0;
    yy_push_state(BINARY);
  }
  HIS[ \t]* {
    utf8_buf_len = 0;
    printf("# ");
    yy_push_state(COMMENT);
  }
  hiss {printf("def");}
  hisS {printf("if ");}
  hiSs {printf("elif ");}
  hiSS {printf("else ");}
  hIss {printf("and ");}
  hIsS {printf("or ");}
  hISs {printf("not ");}
  hISS {printf(", ");}
  Hiss {printf("( ");}
  HisS {printf(") ");}
  HiSs {printf(": ");}
  HiSS {printf("for ");}
  HIss {printf("in ");}
  HIsS {printf("while ");}
  HISs {printf("break ");}
  HISS {printf("continue ");}
  hiis {printf("from ");}
  hiiS {printf("import ");}
  hiIs {printf(".");}
  hiIS {printf("as");}
  hIis {printf("False ");}
  hIiS {printf("None ");}
  hIIs {printf("True ");}
  hIIS {printf("assert ");}
  Hiis {printf("class ");}
  HiiS {printf("del ");}
  HiIs {printf("except ");}
  HiIS {printf("finally ");}
  HIis {printf("is ");}
  HIiS {printf("pass ");}
  HIIs {printf("raise ");}
  HIIS {printf("return ");}
  hhis {printf("try ");}
  hhiS {printf("with ");}
  hhIs {printf("+ ");}
  hhIS {printf("- ");}
  hHis {printf("* ");}
  hHiS {printf("** ");}
  hHIs {printf("/ ");}
  hHIS {printf("// ");}
  Hhis {printf("%% ");}
  HhiS {printf("< ");}
  HhIs {printf("> ");}
  HhIS {printf("<= ");}
  HHis {printf(">= ");}
  HHiS {printf("== ");}
  HHIs {printf("!= ");}
  HHIS {printf("= ");}
  hisss {printf("@ ");}
  hissS {printf("<< ");}
  hisSs {printf(">> ");}
  hisSS {printf("& ");}
  hiSss {printf("| ");}
  hiSsS {printf("^ ");}
  hiSSs {printf("! ");}
  hiSSS {printf("async ");}
  hIsss {printf("await ");}
  hIssS {printf("global ");}
  hIsSs {printf("lambda ");}
  hIsSS {printf("nonlocal ");}
  hISss {printf("yield ");}
  hISsS {printf("; ");}
  hISSs {printf("[ ");}
  hISSS {printf("] ");}
  Hisss {printf("{ ");}
  HissS {printf("} ");}
  HisSs {printf("-> ");}
  HisSS {printf("+= ");}
  HiSss {printf("-= ");}
  HiSsS {printf("*= ");}
  HiSSs {printf("/= ");}
  HiSSS {printf("//= ");}
  HIsss {printf("%%= ");}
  HIssS {printf("@= ");}
  HIsSs {printf("&= ");}
  HIsSS {printf("|= ");}
  HISss {printf("^= ");}
  HISsS {printf(">>= ");}
  HISSs {printf("<<= ");}
  HISSS {printf("**= ");}
  hiiss{NEWLINE}[ \t]* {printf("\\%s",yytext+5); phys_lineno++;}
  hiiss {error(1, "Illegal escape character '\' on line %d.\n", phys_lineno);}
  "{NEWLINE}[ \t]*" {printf("%s", yytext); phys_lineno++; log_lineno++;}
  [hH]+[iI]+[sS]+ {
    getReferencedIdentifier();
    printf("%s ", utf8_buf);
  }
  [ \t]* {/* Consume whitespace */}
}
<ID>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = '\0';
      setIdentifierReference();
    }
    yy_pop_state();
  }
  hiS[ \t] {
    yy_push_state(EMBED);
  }
  {RESERVED} {
    if(getHissIndex() > 64){
      error(1, "Invalid hiss in identifier on line %d.\n", phys_lineno);
    } else {
      utf8_buf[utf8_buf_len++] = getHissIDCharacter();
    }
  }
  [hH]+[iI]+[sS]+ {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = '\0';
      setIdentifierReference();
    }
    addNewIdentifier();
  }
  [ \t] {/* Consume all whitespace */}
  {NEWLINE} {phys_lineno++;}
  . {
    error(1, "Invalid character in identifier on line %d.\n", phys_lineno);
  }
}
<STRING>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    printf("\" ");
    yy_pop_state();
  }
  hiS[ \t] {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    yy_push_state(EMBED);
  }
  [ \t] {/* Consume whitespace */}
  {NEWLINE} {
    phys_lineno++;
  }
  . {
    error(1, "Invalid character in string on line %d.\n", phys_lineno);
  }
}

<COMMENT>{
  {NEWLINE} {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    phys_lineno++;
    log_lineno++;
    printf("\n");
    yy_pop_state();
  }
  . {
    printf("%c", yytext[0]);
  }
}

<STRING,COMMENT>[hH]+[iI]+[sS]+ {
  if(utf8_buf_len > 0){
    utf8_buf[utf8_buf_len] = 0;
    print_escaped_string();
    utf8_buf_len = 0;
  }
  int ind = getHissIndex();
  if(2 <= ind && ind <= 107){
    utf8_buf[0] = getHissStringCharacter();
    utf8_buf[1] = '\0';
    print_escaped_string();
  } else {
    error(1, "Invalid hiss in string on line %d.\n", phys_lineno);
  }
}

<INTEGER>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    yy_pop_state();
  }
  hiS[ \t]* {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    yy_push_state(EMBED);
  }
  [hH]+[iI]+[sS]+ {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    int ind = getHissIndex();
    switch(ind){
      case 2:
        printf("-");
        break;
      case 3:
        printf("0b");
        break;
      case 4:
        printf("0");
        break;
      case 5:
        printf("0x");
        break;
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
        printf("%c",'0'+ind-6);
        break;
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
        printf("%c",'a'+ind-16);
        break;
      default:
        error(1, "Invalid hiss in integer on line %d.\n", phys_lineno);
    }
  }
  [ \t] {
    /* Consume whitespace */
  }
  . {
    error(1, "Invalid character in integer on line %d.\n", phys_lineno);
  }
}

<FLOAT>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    yy_pop_state();
  }
  hiS[ \t]* {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    yy_push_state(EMBED);
  }
  [hH]+[iI]+[sS]+ {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    int ind = getHissIndex();
    switch(ind){
      case 2:
        printf("-");
        break;
      case 3:
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      case 10:
      case 11:
      case 12:
        printf("%c",'0'+ind-3);
        break;
      case 13:
        printf(".");
        break;
      case 14:
        printf("e");
      case 15:
        printf("j");
      default:
        error(1, "Invalid hiss in float on line %d.\n", phys_lineno);
    }
  }
  [ \t] {
    /* Consume whitespace */
  }
  . {
    error(1, "Invalid character in float on line %d.\n", phys_lineno);
  }
}

<EMBED>{
  "his[ \t]*his" {
    utf8_buf_len += sprintf(utf8_buf+utf8_buf_len, "his");
  }
  "his[ \t]*hiS" {
    utf8_buf_len += sprintf(utf8_buf+utf8_buf_len, "hiS");
  }
  [ \t]hiS {
    if(yy_top_state() == INITIAL){
      printf("%s", utf8_buf);
      utf8_buf_len = 0;
    }
    yy_pop_state();
  }
  . {
    utf8_buf_len += sprintf(utf8_buf+utf8_buf_len, "%s", yytext);
  }
}
%%
int n_identifiers = 0;
char* references[100];
char* identifiers[100];
void addNewIdentifier(){
  identifiers[n_identifiers] = malloc(yyleng+1);
  references[n_identifiers] = malloc(yyleng+1);
  strcpy(identifiers[n_identifiers], yytext);
  strcpy(references[n_identifiers], yytext);
  n_identifiers++;
}

void setIdentifierReference(){
  free(references[n_identifiers-1]);
  references[n_identifiers-1] = malloc(utf8_buf_len+1);
  strcpy(references[n_identifiers-1], utf8_buf);
}

void getReferencedIdentifier(){
  for(int i = 0; i < n_identifiers; i++){
    if(strcmp(yytext, identifiers[i]) == 0){
      utf8_buf_len = strlen(references[i]);
      strcpy(utf8_buf, references[i]);
      return;
    }
  }
  addNewIdentifier();
  utf8_buf_len = yyleng;
  strcpy(utf8_buf, yytext);
}

int getHissIndex(){
  int nh = 0, ni = 0, n = 0;
  int index = 0;
  unsigned int bin_offset = 0;
  for(char* p = yytext; *p; p++){
    bin_offset <<= 1;
    n++;
    switch(*p){
      case 'H':
        bin_offset++;
      case 'h':
        nh++;
        break;
      case 'I':
        bin_offset++;
      case 'i':
        ni++;
        break;
      case 'S':
        bin_offset++;
    }
  }
  for(int i = 3; i < n; i++){
    index += (1<<i)*(i-1)*(i-2)/2;
  }
  int n_bin_batches = 0;
  for(int i = 0; i < nh-1; i++){
    n_bin_batches += (n-2-i);
  }
  n_bin_batches += ni-1;
  index += (1<<n)*n_bin_batches;
  index += bin_offset;
  return index;
}

char getHissIDCharacter(){
  int ind = getHissIndex();
  if(ind < 2){
    error(1, "Invalid hiss in ID on line %d.\n", phys_lineno);
  } else if (ind < 12){
    return '0'+ind-2;
  } else if (ind < 38){
    return 'a'+ind-12;
  } else if (ind == 38){
    return '_';
  } else if (ind < 65){
    return 'A'+ind-39;
  } else {
    error(1, "Invalid hiss in ID on line %d.\n", phys_lineno);
  }
}

char getHissStringCharacter(){
  static char shift = 0;
  static char caps = 0;
  int ind = getHissIndex();
  if(ind < 2){
    error(1, "Invalid hiss in string on line %d.\n", phys_lineno);
  } else if(ind < 11){
    switch(ind){
      case 2:
        return '\a';
      case 3:
        return '\b';
      case 4:
        return '\t';
      case 5:
        return '\n';
      case 6:
        return '\v';
      case 7:
        return '\f';
      case 8:
        return '\r';
      case 9:
        shift = 1;
        return '\0';
      case 10:
        caps ^= 1;
        return '\0';
    }
  } else if (ind < 107) {
    char c = ' '+ind-11;
    if (caps^shift && ('a' <= c && c <= 'z')){
      c += 'A'-'a';
    }
    shift = 0;
    return c;
  } else {
    error(1, "Invalid hiss in string on line %d.\n", phys_lineno);
  }
}
void print_escaped_string(){
  for(char* p = utf8_buf; *p; p++){
    switch(*p){
      case '\a':
        printf("\\a");
        break;
      case '\b':
        printf("\\b");
        break;
      case '\t':
        printf("\\t");
        break;
      case '\n':
        printf("\\n");
        break;
      case '\v':
        printf("\\v");
        break;
      case '\f':
        printf("\\f");
        break;
      case '\r':
        printf("\\r");
        break;
      case '\\':
        printf("\\\\");
        break;
      case '"':
        printf("\\\"");
        break;
      default:
        printf("%c", *p);
    }
  }
}

void error(int exit_code, const char* error_fmt, ...){
  va_list args;
  va_start(args, error_fmt);
  fprintf(stderr, "Error: ");
  vfprintf(stderr, error_fmt, args);
  for(int i = 0; i < n_identifiers; i++){
    free(identifiers[i]);
    free(references[i]);
  }
  exit(exit_code);
}

int main(){
  yylex();
  for(int i = 0; i < n_identifiers; i++){
    free(identifiers[i]);
    free(references[i]);
  }
}
