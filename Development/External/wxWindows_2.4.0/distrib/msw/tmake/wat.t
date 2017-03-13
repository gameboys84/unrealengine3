#!#############################################################################
#! File:    wat.t
#! Purpose: tmake template file from which makefile.wat is generated by running
#!          tmake -t wat wxwin.pro -o makefile.wat
#!          TODO:
#!            - extended.c, unzip.c must be compiled with $(CC), not $(CCC).
#!            - extended.c, unzip.c targets must be as per b32.t etc.
#!            - OLE files not generated correctly (need 'ole/' directory)
#! Author:  Vadim Zeitlin
#! Created: 14.07.99
#! Version: $Id: wat.t,v 1.14 2002/02/02 23:15:23 VS Exp $
#!#############################################################################
#${
    #! include the code which parses filelist.txt file and initializes
    #! %wxCommon, %wxGeneric and %wxMSW hashes.
    IncludeTemplate("filelist.t");

    #! now transform these hashes into $project tags
    foreach $file (sort keys %wxGeneric) {
        my $tag = "";
        if ( $wxGeneric{$file} =~ /\b(PS|G|16|U)\b/ ) {
            $tag = "WXNONESSENTIALOBJS";
        }
        else {
            $tag = "WXGENERICOBJS";
        }

        $file =~ s/cp?p?$/obj/;
        $project{$tag} .= $file . " "
    }
    
    foreach $file (sort keys %wxHTML) {
        next if $wxHTML{$file} =~ /\b16\b/;

        $file =~ s/cp?p?$/obj/;
        $project{"WXHTMLOBJS"} .= $file . " "
    }

    foreach $file (sort keys %wxCommon) {
        next if $wxCommon{$file} =~ /\b(16|U)\b/;

        $isCFile = $file =~ /\.c$/;
        $file =~ s/cp?p?$/obj/;
        $project{"WXCOMMONOBJS"} .= $file . " ";
        $project{"WXCOBJS"} .= $file . " " if $isCFile;
    }

    foreach $file (sort keys %wxMSW) {
        #! these files don't compile
        next if $file =~ /^pnghand\./;

#!        next if $wxGeneric{$file} =~ /\b16\b/;

        my $isOleObj = $wxMSW{$file} =~ /\bO\b/;
        my $isCFile = $file =~ /\.c$/;
        $file =~ s/cp?p?$/obj/;
        $project{"WXMSWOBJS"} .= $file . " ";
        $project{"WXCOBJS"} .= $file . " " if $isCFile;
        $project{"WXOLEOBJS"} .= $file . " " if $isOleObj
    }
#$}
#! an attempt to embed '#' directly in the string somehow didn't work...
#$ $text = chr(35) . '!/binb/wmake.exe';

# This file was automatically generated by tmake 
# DO NOT CHANGE THIS FILE, YOUR CHANGES WILL BE LOST! CHANGE WAT.T!

#
# File:     makefile.wat
# Author:   Julian Smart
# Created:  1998
#
# Makefile : Builds wxWindows library for Watcom C++, WIN32
#
# NOTE: This file is generated from wat.t by tmake, but not all bugs have
# been removed from this process. If wxWindows doesn't compile,
# check the following and edit this makefile accordingly:
#
# - OLE-related files such as oleutils.cpp should have 'ole\' prepended
#   to the path.
# - extended.c, gsocket.c, unzip.c must be compiled using $(CC), not $(CCC).
#   They may also be wrongly specified as extended.cpp, etc.

WXDIR = ..\..

!include $(WXDIR)\src\makewat.env

WXLIB = $(WXDIR)\lib

LIBTARGET   = $(WXLIB)\wx.lib
DUMMY=dummydll
# ODBCLIB     = ..\..\contrib\odbc\odbc32.lib

EXTRATARGETS = png zlib jpeg tiff regex
EXTRATARGETSCLEAN = clean_png clean_zlib clean_jpeg clean_tiff clean_regex
GENDIR=$(WXDIR)\src\generic
COMMDIR=$(WXDIR)\src\common
JPEGDIR=$(WXDIR)\src\jpeg
TIFFDIR=$(WXDIR)\src\tiff
MSWDIR=$(WXDIR)\src\msw
OLEDIR=$(MSWDIR)\ole
HTMLDIR=$(WXDIR)\src\html

DOCDIR = $(WXDIR)\docs

GENERICOBJS= #$ ExpandGlue("WXGENERICOBJS", "", " &\n\t")

# These are generic things that don't need to be compiled on MSW,
# but sometimes it's useful to do so for testing purposes.
NONESSENTIALOBJS= #$ ExpandGlue("WXNONESSENTIALOBJS", "", " &\n\t")

COMMONOBJS = &
	y_tab.obj &
	#$ ExpandGlue("WXCOMMONOBJS", "", " &\n\t")

MSWOBJS = #$ ExpandGlue("WXMSWOBJS", "", " &\n\t")

HTMLOBJS = #$ ExpandGlue("WXHTMLOBJS", "", " &\n\t")

# Add $(NONESSENTIALOBJS) if wanting generic dialogs, PostScript etc.
OBJECTS = $(COMMONOBJS) $(GENERICOBJS) $(MSWOBJS) $(HTMLOBJS)

ARCHINCDIR=$(WXDIR)\lib\msw
SETUP_H=$(ARCHINCDIR)\wx\setup.h

all:        $(SETUP_H) $(OBJECTS) $(LIBTARGET) $(EXTRATARGETS) .SYMBOLIC

$(ARCHINCDIR)\wx:
    mkdir $(ARCHINCDIR)
    mkdir $(ARCHINCDIR)\wx

$(SETUP_H): $(WXDIR)\include\wx\msw\setup.h $(ARCHINCDIR)\wx
    copy $(WXDIR)\include\wx\msw\setup.h $@

$(LIBTARGET) : $(OBJECTS)
    %create tmp.lbc
    @for %i in ( $(OBJECTS) ) do @%append tmp.lbc +%i
    wlib /b /c /n /p=512 $^@ @tmp.lbc

#test : $(OBJECTS)
#    %create tmp.lbc
#    @for %i in ( $(OBJECTS) ) do @%append tmp.lbc +%i
#    wlib /b /c /n /p=512 $^@ @tmp.lbc


clean:   .SYMBOLIC $(EXTRATARGETSCLEAN)
    -erase *.obj
    -erase $(LIBTARGET)
    -erase *.pch
    -erase *.err
    -erase *.lbc

cleanall:   clean

#${
    $_ = $project{"WXMSWOBJS"};
    my @objs = split;
    foreach (@objs) {
        $text .= $_ . ':     $(';
        s/\.obj$//;
        if ( $project{"WXOLEOBJS"} =~ /\b\Q$_\E\b/ ) {
            $text .= 'OLEDIR)\\';
        } else {
            $text .= 'MSWDIR)\\';
        }
        my $suffix, $cc;
        if ( $project{"WXCOBJS"} =~ /\b\Q$_\E\b/ ) {
            $suffix = "c";
            $cc="CC";
        }
        else {
            $suffix = "cpp";
            $cc="CCC";
        }
        $text .= $_ . ".$suffix\n" .
                 "  *\$($cc) \$(CPPFLAGS) \$(IFLAGS) \$<" . "\n\n";
    }
#$}

########################################################
# Common objects (always compiled)

#${
    $_ = $project{"WXCOMMONOBJS"};
    my @objs = split;
    foreach (@objs) {
        $text .= $_;
        s/\.obj$//;
        $text .= ':     $(COMMDIR)\\';
        my $suffix, $cc;
        if ( $project{"WXCOBJS"} =~ /\b\Q$_\E\b/ ) {
            $suffix = "c";
            $cc="CC";
        }
        else {
            $suffix = "cpp";
            $cc="CCC";
        }
        $text .= $_ . ".$suffix\n" .
                 "  *\$($cc) \$(CPPFLAGS) \$(IFLAGS) \$<" . "\n\n";
    }
#$}

y_tab.obj:     $(COMMDIR)\y_tab.c $(COMMDIR)\lex_yy.c
  *$(CC) $(CPPFLAGS) $(IFLAGS) -DUSE_DEFINE $(COMMDIR)\y_tab.c

#  *$(CC) $(CPPFLAGS) $(IFLAGS) -DUSE_DEFINE -DYY_USE_PROTOS $(COMMDIR)\y_tab.c

$(COMMDIR)\y_tab.c:     $(COMMDIR)\dosyacc.c
        copy $(COMMDIR)\dosyacc.c $(COMMDIR)\y_tab.c

$(COMMDIR)\lex_yy.c:    $(COMMDIR)\doslex.c
    copy $(COMMDIR)\doslex.c $(COMMDIR)\lex_yy.c

########################################################
# Generic objects (not always compiled, depending on
# whether platforms have native implementations)

#${
    $_ = $project{"WXGENERICOBJS"};
    my @objs = split;
    foreach (@objs) {
        $text .= $_;
        s/\.obj$//;
        $text .= ':     $(GENDIR)\\';
        $text .= $_ . ".cpp\n" .
                 '  *$(CCC) $(CPPFLAGS) $(IFLAGS) $<' . "\n\n";
    }
#$}


########################################################
# HTML objects (always compiled)

#${
    $_ = $project{"WXHTMLOBJS"};
    my @objs = split;
    foreach (@objs) {
        $text .= $_;
        s/\.obj$//;
        $text .= ':     $(HTMLDIR)\\';
        $text .= $_ . ".cpp\n" .
                 '  *$(CCC) $(CPPFLAGS) $(IFLAGS) $<' . "\n\n";
    }
#$}

png:   .SYMBOLIC
    cd $(WXDIR)\src\png
    wmake -f makefile.wat all
    cd $(WXDIR)\src\msw

clean_png:   .SYMBOLIC
    cd $(WXDIR)\src\png
    wmake -f makefile.wat clean
    cd $(WXDIR)\src\msw

zlib:   .SYMBOLIC
    cd $(WXDIR)\src\zlib
    wmake -f makefile.wat all
    cd $(WXDIR)\src\msw

clean_zlib:   .SYMBOLIC
    cd $(WXDIR)\src\zlib
    wmake -f makefile.wat clean
    cd $(WXDIR)\src\msw

jpeg:    .SYMBOLIC
    cd $(WXDIR)\src\jpeg
    wmake -f makefile.wat all
    cd $(WXDIR)\src\msw

clean_jpeg:   .SYMBOLIC
    cd $(WXDIR)\src\jpeg
    wmake -f makefile.wat clean
    cd $(WXDIR)\src\msw

tiff:    .SYMBOLIC
    cd $(WXDIR)\src\tiff
    wmake -f makefile.wat all
    cd $(WXDIR)\src\msw

clean_tiff:   .SYMBOLIC
    cd $(WXDIR)\src\tiff
    wmake -f makefile.wat clean
    cd $(WXDIR)\src\msw

regex:    .SYMBOLIC
    cd $(WXDIR)\src\regex
    wmake -f makefile.wat all
    cd $(WXDIR)\src\msw

clean_regex:   .SYMBOLIC
    cd $(WXDIR)\src\regex
    wmake -f makefile.wat clean
    cd $(WXDIR)\src\msw

MFTYPE=wat
self : .SYMBOLIC $(WXDIR)\distrib\msw\tmake\filelist.txt $(WXDIR)\distrib\msw\tmake\$(MFTYPE).t
	cd $(WXDIR)\distrib\msw\tmake
	tmake -t $(MFTYPE) wxwin.pro -o makefile.$(MFTYPE)
	copy makefile.$(MFTYPE) $(WXDIR)\src\msw