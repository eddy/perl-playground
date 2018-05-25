#!/usr/bin/perl -n -l

if ( /^<CP>(\S+)/ ) {
    $lcp = $cp;
    $lid = $id;
    $cp = $_;
    $id = $1;
    # print "Found CP: $cp ($id)";
    ($cp_pagecount) = $lcp =~ /\d{3}[NY]{6}(\d{6})/;
    ($footer_pagecount) = $footer =~ /(\d)\/1-1/;

    $delta = $cp_pagecount - $footer_pagecount;
    print "[$lcp] [$footer] [$cp_pagecount] [$footer_pagecount] [discrepancy: $delta]" if ($delta != 0);
}

if ( /\d\/1-1/ ) {
    $footer = $_;
#    print "[$lcp] [$lfooter]" if ($lid ne $id);
#    print "Found Footer: $footer";
#    print "Last ID: $lid, CurrentID: $id";
}

#####[<CP>420424409T                    000NNNNNN000002000004                       ] [<FT16><AP1182,3456>2/1-1]

__END__

This simple script is used to count the number of discrepancy of
document we get from the <CP> and the [1/1-1]

Input: *.ibs3
Output: .......... [discrepancy = 1]

It counts the total number of <CP> in the *.ibs3 file (output after 
doc-builder) and compares to the biggest number in <FT16><AP1182,3456>3/1-1

If there's discrepancy, it'd be reported so we get a reference to the
document
