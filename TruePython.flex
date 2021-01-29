%{
  #include <stdio.h>
  #include "tracking_printf.h"
  #include "color_printf.h"
  #define BUFLEN 100

  typedef unsigned char utf8;

  unsigned int lineno = 0;
  unsigned char utf8_buf[BUFLEN+1];
  unsigned int utf8_buf_len;

  void addNewIdentifier();
  void getReferencedIdentifier();
  void setIdentifierReference();
  int getHissIndex();
  char getHissIDCharacter();
  char getHissStringCharacter();
  void print_escaped_string();
  void error(int exit_code, const char* error_fmt, ...);
  void info(const char* info_fmt, ...);
%}
NEWLINE \r\n?|\n
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
  his {error(1, "Encountered unmatched end on line %d.\n", lineno);}
  hiS[ \t] {
    utf8_buf_len = 0;
    info("Begin embed");
    yy_push_state(EMBED);
  }
  hIs[ \t]* {
    utf8_buf_len = 0;
    info("Begin ID");
    yy_push_state(ID);
  }
  hIS[ \t]* {
    utf8_buf_len = 0;
    tprintf("\"");
    info("Begin string");
    yy_push_state(STRING);
  }
  His[ \t]* {
    utf8_buf_len = 0;
    info("Begin integer");
    yy_push_state(INTEGER);
  }
  HiS[ \t]* {
    utf8_buf_len = 0;
    info("Begin float");
    yy_push_state(FLOAT);
  }
  HIs[ \t]* {
    utf8_buf_len = 0;
    info("Begin binary");
    yy_push_state(BINARY);
  }
  HIS[ \t]* {
    utf8_buf_len = 0;
    tprintf("# ");
    info("Begin comment");
    yy_push_state(COMMENT);
  }
  hiss {tprintf("def ");}
  hisS {tprintf("if ");}
  hiSs {tprintf("elif ");}
  hiSS {tprintf("else ");}
  hIss {tprintf("and ");}
  hIsS {tprintf("or ");}
  hISs {tprintf("not ");}
  hISS {tprintf(", ");}
  Hiss {tprintf("( ");}
  HisS {tprintf(") ");}
  HiSs {tprintf(": ");}
  HiSS {tprintf("for ");}
  HIss {tprintf("in ");}
  HIsS {tprintf("while ");}
  HISs {tprintf("break ");}
  HISS {tprintf("continue ");}
  hiis {tprintf("from ");}
  hiiS {tprintf("import ");}
  hiIs {tprintf(".");}
  hiIS {tprintf("as");}
  hIis {tprintf("False ");}
  hIiS {tprintf("None ");}
  hIIs {tprintf("True ");}
  hIIS {tprintf("assert ");}
  Hiis {tprintf("class ");}
  HiiS {tprintf("del ");}
  HiIs {tprintf("except ");}
  HiIS {tprintf("finally ");}
  HIis {tprintf("is ");}
  HIiS {tprintf("pass ");}
  HIIs {tprintf("raise ");}
  HIIS {tprintf("return ");}
  hhis {tprintf("try ");}
  hhiS {tprintf("with ");}
  hhIs {tprintf("+ ");}
  hhIS {tprintf("- ");}
  hHis {tprintf("* ");}
  hHiS {tprintf("** ");}
  hHIs {tprintf("/ ");}
  hHIS {tprintf("// ");}
  Hhis {tprintf("%% ");}
  HhiS {tprintf("< ");}
  HhIs {tprintf("> ");}
  HhIS {tprintf("<= ");}
  HHis {tprintf(">= ");}
  HHiS {tprintf("== ");}
  HHIs {tprintf("!= ");}
  HHIS {tprintf("= ");}
  hisss {tprintf("@ ");}
  hissS {tprintf("<< ");}
  hisSs {tprintf(">> ");}
  hisSS {tprintf("& ");}
  hiSss {tprintf("| ");}
  hiSsS {tprintf("^ ");}
  hiSSs {tprintf("! ");}
  hiSSS {tprintf("async ");}
  hIsss {tprintf("await ");}
  hIssS {tprintf("global ");}
  hIsSs {tprintf("lambda ");}
  hIsSS {tprintf("nonlocal ");}
  hISss {tprintf("yield ");}
  hISsS {tprintf("; ");}
  hISSs {tprintf("[ ");}
  hISSS {tprintf("] ");}
  Hisss {tprintf("{ ");}
  HissS {tprintf("} ");}
  HisSs {tprintf("-> ");}
  HisSS {tprintf("+= ");}
  HiSss {tprintf("-= ");}
  HiSsS {tprintf("*= ");}
  HiSSs {tprintf("/= ");}
  HiSSS {tprintf("//= ");}
  HIsss {tprintf("%%= ");}
  HIssS {tprintf("@= ");}
  HIsSs {tprintf("&= ");}
  HIsSS {tprintf("|= ");}
  HISss {tprintf("^= ");}
  HISsS {tprintf(">>= ");}
  HISSs {tprintf("<<= ");}
  HISSS {tprintf("**= ");}
  hiiss{NEWLINE}[ \t]* {tprintf("\\%s",yytext+5); lineno++;}
  hiiss {error(1, "Illegal escape character '\' on line %d.\n", lineno);}
  {NEWLINE}[ \t]* {tprintf("%s", yytext); lineno++;}
  [hH]+[iI]+[sS]+ {
    getReferencedIdentifier();
    tprintf("%s ", (char*)utf8_buf);
  }
  [ \t]* {/* Consume whitespace */}
}
<ID>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = '\0';
      setIdentifierReference();
    }
    info("End ID");
    yy_pop_state();
  }
  hiS[ \t] {
    info("Begin embed");
    yy_push_state(EMBED);
  }
  {RESERVED} {
    if(getHissIndex() > 64){
      error(1, "Invalid hiss in identifier on line %d.\n", lineno);
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
  {NEWLINE} {lineno++;}
  . {
    error(1, "Invalid character in identifier on line %d.\n", lineno);
  }
}
<STRING>{
  his[ \t]* {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    tprintf("\"");
    tprintf("%s", yytext+3);
    info("End string");
    yy_pop_state();
  }
  hiS[ \t] {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    info("Begin embed");
    yy_push_state(EMBED);
  }
  [ \t] {/* Consume whitespace */}
  {NEWLINE} {
    lineno++;
  }
  . {
    error(1, "Invalid character in string on line %d.\n", lineno);
  }
}

<COMMENT>{
  {NEWLINE} {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    lineno++;
    tprintf("\n");
    info("End comment");
    yy_pop_state();
  }
  . {
    tprintf("%c", yytext[0]);
  }
}

<STRING,COMMENT>[hH]+[iI]+[sS]+[ \t]* {
  if(utf8_buf_len > 0){
    utf8_buf[utf8_buf_len] = 0;
    print_escaped_string();
    utf8_buf_len = 0;
  }
  int ind = getHissIndex();
  if(2 <= ind && ind <= 107){
    utf8_buf[0] = getHissStringCharacter();
    utf8_buf[1] = '\0';
    info("String hiss code for %s", utf8_buf);
    print_escaped_string();
  } else {
    error(1, "Invalid hiss \"%s\" in string on line %d.\n", yytext, lineno);
  }
}

<INTEGER>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    info("End integer");
    yy_pop_state();
  }
  hiS[ \t]* {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    info("Begin embed");
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
        tprintf("-");
        break;
      case 3:
        tprintf("0b");
        break;
      case 4:
        tprintf("0");
        break;
      case 5:
        tprintf("0x");
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
        tprintf("%c",'0'+ind-6);
        break;
      case 16:
      case 17:
      case 18:
      case 19:
      case 20:
      case 21:
        tprintf("%c",'a'+ind-16);
        break;
      default:
        error(1, "Invalid hiss in integer on line %d.\n", lineno);
    }
  }
  [ \t] {
    /* Consume whitespace */
  }
  . {
    error(1, "Invalid character in integer on line %d.\n", lineno);
  }
  {NEWLINE} {lineno++;}
}

<FLOAT>{
  his {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    info("End float");
    yy_pop_state();
  }
  hiS[ \t]* {
    if(utf8_buf_len > 0){
      utf8_buf[utf8_buf_len] = 0;
      print_escaped_string();
      utf8_buf_len = 0;
    }
    info("Begin embed");
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
        tprintf("-");
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
        tprintf("%c",'0'+ind-3);
        break;
      case 13:
        tprintf(".");
        break;
      case 14:
        tprintf("e");
      case 15:
        tprintf("j");
      default:
        error(1, "Invalid hiss in float on line %d.\n", lineno);
    }
  }
  [ \t] {
    /* Consume whitespace */
  }
  . {
    error(1, "Invalid character in float on line %d.\n", lineno);
  }
  {NEWLINE} {lineno++;}
}

<EMBED>{
  "his[ \t]*his" {
    utf8_buf_len += sprintf((char*)utf8_buf+utf8_buf_len, "his");
  }
  "his[ \t]*hiS" {
    utf8_buf_len += sprintf((char*)utf8_buf+utf8_buf_len, "hiS");
  }
  [ \t]hiS {
    if(yy_top_state() == INITIAL){
      printf("%s", (char*)utf8_buf);
      utf8_buf_len = 0;
    }
    info("End embed");
    yy_pop_state();
  }
  .|\n {
    utf8_buf_len += sprintf((char*)utf8_buf+utf8_buf_len, "%s", yytext);
  }
}
%%
int n_identifiers = 0;
char* references[100];
char* identifiers[100];
void addNewIdentifier(){
  info("Adding new identifier %s", yytext);;
  identifiers[n_identifiers] = malloc(yyleng+1);
  references[n_identifiers] = malloc(yyleng+1);
  strcpy(identifiers[n_identifiers], yytext);
  strcpy(references[n_identifiers], yytext);
  n_identifiers++;
}

void setIdentifierReference(){
  info("Set identifier %s to reference %s", identifiers[n_identifiers-1], utf8_buf);
  free(references[n_identifiers-1]);
  references[n_identifiers-1] = malloc(utf8_buf_len+1);
  strcpy(references[n_identifiers-1], (char*)utf8_buf);
}

void getReferencedIdentifier(){
  for(int i = 0; i < n_identifiers; i++){
    if(strcmp(yytext, identifiers[i]) == 0){
      info("Found identifier %s referencing %s", yytext, references[i]);
      utf8_buf_len = strlen(references[i]);
      strcpy((char*)utf8_buf, references[i]);
      return;
    }
  }
  addNewIdentifier();
  utf8_buf_len = yyleng;
  strcpy((char*)utf8_buf, yytext);
}

int getHissIndex(){
  int nh = 0, ni = 0, n = 0;
  int index = 0;
  unsigned int bin_offset = 0;
  for(char* p = yytext; *p; p++){
    if (*p == ' ' || *p == '\t') break;
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
    error(1, "Invalid hiss in ID on line %d.\n", lineno);
  } else if (ind < 12){
    return '0'+ind-2;
  } else if (ind < 38){
    return 'a'+ind-12;
  } else if (ind == 38){
    return '_';
  } else if (ind < 65){
    return 'A'+ind-39;
  } else {
    error(1, "Invalid hiss in ID on line %d.\n", lineno);
  }
  return -1;
}

char getHissStringCharacter(){
  static bool shift = false;
  static bool caps = false;
  int ind = getHissIndex();
  if(ind < 2){
    error(1, "Invalid hiss \"%s\" in string on line %d.\n", yytext, lineno);
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
    error(1, "Invalid hiss \"%s\" in string on line %d.\n", yytext, lineno);
  }
  return -1;
}
void print_escaped_string(){
  for(utf8* p = utf8_buf; *p; p++){
    if (*p < 0x20 || 0x7F < *p){
      tprintf("\\x%02x",*p);
    } else if (*p == '\\'){
      tprintf("\\\\");
    } else if (*p == '"'){
      tprintf("\\\"");
    } else {
      tprintf("%c",*p);
    }
  }
}

void error(int exit_code, const char* error_fmt, ...){
  va_list args;
  va_start(args, error_fmt);
  fprintf(stderr, "\x1b[31mError: ");
  vfprintf(stderr, error_fmt, args);
  for(int i = 0; i < n_identifiers; i++){
    free(identifiers[i]);
    free(references[i]);
  }
  fprintf(stderr, "\x1b[0m\n");
  va_end(args);
  exit(exit_code);
}

void info(const char* info_fmt, ...){
  va_list args;
  va_start(args, info_fmt);
  fprintf(stderr, "\x1b[1;36mInfo: ");
  vfprintf(stderr, info_fmt, args);
  fprintf(stderr, "\x1b[0m\n");
  va_end(args);
}

int main(){
  yylex();
  for(int i = 0; i < n_identifiers; i++){
    free(identifiers[i]);
    free(references[i]);
  }
}
