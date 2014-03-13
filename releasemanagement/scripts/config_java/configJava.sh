#!/bin/bash
#
# Script for setting JAVA_HOME Variable.
#
#clear

#
# Checking to see what type of machine.
#	32 bit or 64Bit OS.
#

# pass the direct JAVA id without getting the full JDK list, useful for fast JDK selection if you know in advance the JAVA_ID
JAVA_ID=$1

if [ `uname -m` == "x86_64" ]; then
        M_TYPE=64
fi
if [ `uname -m` == "i686" ]; then
        M_TYPE=32
fi
if [ `uname -m` == "ppc64" ]; then
        M_TYPE=ppc64
fi


#this function prints 32bit available jdks
print_32bit_jdk()
{
	echo -e '\E[37;44m'" \033[1m   Java For 32 Bit machine    \033[0m"
	echo -e '\E[37;44m'" \033[1m  Please select Java platform:\033[0m"
#	echo " Java For 32 Bit machine..."
#	echo "Please select Java platform:"
#	echo "-------- Sun JDK 1.4 -------"
	echo -e "\033[1m-------- Sun JDK 1.4 -------\033[0m"
	echo -e "\033[1m   1) Latest: Sun JDK 1.4.2 16 \033[0m"
	echo -e "\033[1m   2)\033[0m  Sun JDK 1.4.2 10"
	echo -e "\033[1m   3)\033[0m  Sun JDK 1.4.2 12"
	echo -e "\033[1m   4)\033[0m  Sun JDK 1.4.2 16"
#	echo " ------- Sun JDK 1.5 -------"
 	echo -e "\033[1m-------- Sun JDK 1.5 -------\033[0m"
	echo -e "\033[1m   10) Latest: Sun JDK 1.5.0 19 \033[0m"
	echo -e "\033[1m   11)\033[0m  Sun JDK 1.5.0 12"
	echo -e "\033[1m   12)\033[0m  Sun JDK 1.5.0 13"
	echo -e "\033[1m   13)\033[0m  Sun JDK 1.5.0 16"
	echo -e "\033[1m   14)\033[0m  Sun JDK 1.5.0 17"
	echo -e "\033[1m   15)\033[0m  Sun JDK 1.5.0 19"
	echo -e "\033[1m-------- Sun JDK 1.6 ------- \033[0m"
	echo -e "\033[1m   20) Latest: Sun JDK 1.6.0 Update 18\033[0m "
	echo -e "\033[1m   21)\033[0m  Sun JDK 1.6.0 Update 14"
	echo -e "\033[1m   22)\033[0m  Sun JDK 1.6.0 Update 17"
	echo -e "\033[1m   23)\033[0m  Sun JDK 1.6.0 Update 18"

	echo -e "\033[1m ------- Sun JDK 7.0 -------\033[0m"
        echo -e "\033[1m   72) Latest: Sun JDK 7.0 Early Access b78 32Bit\033[0m "

	echo -e "\033[1m------- JRockit 1.5 Jdk's ------\033[0m"
	echo -e "\033[1m   30) Latest: JRockit JDK 1.5.0 12 \033[0m"
	echo -e "\033[1m   31)\033[0m JRockit JDK 1.5.0 04"
        echo -e "\033[1m   32)\033[0m JRockit JDK 1.5.0 12"

        echo -e "\033[1m ------- JRockit 1.6 Jdk's -------\033[0m"
        echo -e "\033[1m   40) Latest: Jrockit JRRT 1.6.0_20 Rev 28.0.1\033[0m"
        echo -e "\033[1m   41)\033[0m JRockit JDK 1.6.0 Rev 27.2.0"
        echo -e "\033[1m   42)\033[0m JRocket JDK 1.6.0 Rev 27.4.0"
        echo -e "\033[1m   43)\033[0m JRocket JRRT 1.6.0_20 Rev 28.0.1"

	echo -e "\033[1m------- IBM 1.4 Jdk's ------\033[0m"
	echo -e "\033[1m   50) Latest: IBM JDK 1.4.2 Ver 09 \033[0m"
	echo -e "\033[1m   51)\033[0m IBM JDK 1.4.2"
	echo -e "\033[1m   52)\033[0m IBM JDK 1.4.2 Ver 09"

	echo -e "\033[1m------- IBM 1.5 Jdk's ------\033[0m"
	echo -e "\033[1m   60) Latest: IBM JDK 1.5 \033[0m"
	echo -e "\033[1m   61)\033[0m IBM JDK 1.5"

	echo -e "\033[1m------- IBM 1.6 Jdk's ------\033[0m"
	echo -e "\033[1m   62) Latest: IBM JDK 1.6 \033[0m"
	echo -e "\033[1m   63)\033[0m IBM JDK 1.5"

	echo ""
}

#print all available jdks, this function will be called only on 64bit machine
print_all_jdk()
{
	#
	#	If not 32Bit then 64Bit, run the following:
	#
	echo -e '\E[37;43m'" \033[1m  Java For 64 Bit machine...\033[0m"
	echo -e '\E[37;43m'" \033[1mPlease select Java platform:\033[0m"
#	echo " Java For 64 Bit machine..."
#	echo "Please select Java platform:"
#	echo " ------- Sun JDK 1.4 -------"
	echo -e "\033[1m ------- Sun JDK 1.4 -------\033[0m"
        echo -e "\033[1m   1) Latest: Sun JDK 1.4.2 16 \033[0m"
        echo -e "\033[1m   2)\033[0m  Sun JDK 1.4.2 10"
        echo -e "\033[1m   3)\033[0m  Sun JDK 1.4.2 12"
        echo -e "\033[1m   4)\033[0m  Sun JDK 1.4.2 16"

	echo -e "\033[1m ------- Sun JDK 1.5 -------\033[0m"
        echo -e "\033[1m   10) Latest: Sun JDK 1.5.0 22 64Bit\033[0m"
        echo -e "\033[1m   11)\033[0m  Sun JDK 1.5.0 12"
        echo -e "\033[1m   12)\033[0m  Sun JDK 1.5.0 13 64Bit"
        echo -e "\033[1m   12a)\033[0m  Sun JDK 1.5.0 13"
        echo -e "\033[1m   13)\033[0m  Sun JDK 1.5.0 16 64Bit"
        echo -e "\033[1m   13a)\033[0m  Sun JDK 1.5.0 16"
        echo -e "\033[1m   14)\033[0m  Sun JDK 1.5.0 17 64Bit"
        echo -e "\033[1m   14a)\033[0m  Sun JDK 1.5.0 17"
	echo -e "\033[1m   15)\033[0m  Sun JDK 1.5.0 19 64Bit"
	echo -e "\033[1m   15a)\033[0m  Sun JDK 1.5.0 19"
	echo -e "\033[1m   16)\033[0m  Sun JDK 1.5.0 22 64Bit"

	echo -e "\033[1m ------- Sun JDK 1.6 -------\033[0m"
	echo -e "\033[1m   20) Latest: Sun JDK 1.6.0 Update 43 64Bit\033[0m "
        echo -e "\033[1m   21)\033[0m  Sun JDK 1.6.0 23 64Bit"
        echo -e "\033[1m   22)\033[0m  Sun JDK 1.6.0 24 64Bit"
        echo -e "\033[1m   23)\033[0m  Sun JDK 1.6.0 25 64Bit"
        echo -e "\033[1m   24)\033[0m  Sun JDK 1.6.0 26 64Bit"
        echo -e "\033[1m   25)\033[0m  Sun JDK 1.6.0 27 64Bit"
        echo -e "\033[1m   26)\033[0m  Sun JDK 1.6.0 30 64Bit"
        echo -e "\033[1m   27)\033[0m  Sun JDK 1.6.0 31 64Bit"
        echo -e "\033[1m   28)\033[0m  Sun JDK 1.6.0 37 64Bit"
        echo -e "\033[1m   29)\033[0m  Sun JDK 1.6.0 43 64Bit"

        echo -e "\033[1m ------- Sun JDK 7.0 -------\033[0m"
        echo -e "\033[1m   70) Latest: Sun JDK 7.0 45 64Bit\033[0m "
        echo -e "\033[1m   71)\033[0m  Sun JDK 7.0 09 64Bit\033[0m "
        echo -e "\033[1m   72)\033[0m  Sun JDK 7.0 13 64Bit\033[0m "
        echo -e "\033[1m   73)\033[0m  Sun JDK 7.0 17 64Bit\033[0m "
        echo -e "\033[1m   74)\033[0m  Sun JDK 7.0 21 64Bit\033[0m "
        echo -e "\033[1m   75)\033[0m  Sun JDK 7.0 45 64Bit\033[0m "

	echo -e "\033[1m ------- Jrockit 1.5 Jdk's -------\033[0m"
	echo -e "\033[1m   30) Latest: Jrockit JDK 1.5.0 12 64Bit\033[0m"
	echo -e "\033[1m   31)\033[0m Jrockit JDK 1.5.0 04"
	echo -e "\033[1m   32)\033[0m Jrockit JDK 1.5.0 12 64Bit"
	echo -e "\033[1m   32a)\033[0m Jrockit JDK 1.5.0 12"

	echo -e "\033[1m ------- Jrockit 1.6 Jdk's -------\033[0m"
	echo -e "\033[1m   40) Latest: Jrockit JDK 1.6.0_31 R28.2.3 4.1.0 64Bit\033[0m"
	echo -e "\033[1m   41)\033[0m Jrockit JDK 1.6.0 Rev 27.2.0 64Bit"
	echo -e "\033[1m   41a)\033[0m Jrockit JDK 1.6.0 Rev 27.2.0"
	echo -e "\033[1m   42)\033[0m Jrockit JDK 1.6.0 Rev 27.4.0 64Bit"
	echo -e "\033[1m   42a)\033[0m Jrockit JDK 1.6.0 Rev 27.4.0"
	echo -e "\033[1m   43)\033[0m Jrockit JRRT 1.6.0_20 Rev 28.0.1 64Bit"
	echo -e "\033[1m   44)\033[0m Jrockit JDK 1.6.0_31 R28.2.3 4.1.0 64Bit"


	echo -e "\033[1m------- IBM 1.6 Jdk's ------\033[0m"
	echo -e "\033[1m   60) Latest: IBM JDK 1.6 64-bit_u12\033[0m"

	echo -e "\033[1m------- IBM 1.7 Jdk's ------\033[0m"
	echo -e "\033[1m   65) Latest: IBM JDK 1.7 64Bit SR6\033[0m"	
	echo -e "\033[1m   66)\033[0m  IBM JDK 7.0 64Bit SR3\033[0m "
	echo -e "\033[1m   67)\033[0m  IBM JDK 7.0 64Bit SR5\033[0m "
	echo -e "\033[1m   68)\033[0m  IBM JDK 7.0 64Bit SR6\033[0m "

	echo -e "\033[1m------- AZUL 1.6 Jdk's PC_LAB63 ONLY------\033[0m"
	echo -e "\033[1m   99) AZUL JDK 1.6 64-bit \033[0m"

	echo ""
}
print_ppc64()
{
	echo -e "\033[1m ------- Sun JDK 1.4 -------\033[0m"
        echo -e "\033[1m   1) Latest: Sun JDK 1.4.2 09 64Bit \033[0m"
        echo -e "\033[1m   1a) Latest: Sun JDK 1.4.2 09 32Bit \033[0m"
	echo -e "\033[1m ------- Sun JDK 1.5 -------\033[0m"
        echo -e "\033[1m   18) Latest: Sun JDK 1.5.0 16 64Bit\033[0m"
        echo -e "\033[1m   18a) Latest: Sun JDK 1.5.0 16 32Bit\033[0m"
	echo -e "\033[1m ------- Sun JDK 1.6 -------\033[0m"
        echo -e "\033[1m   20) Latest: Sun JDK 1.6.0 03 64Bit\033[0m "
        echo -e "\033[1m   20a) Latest: Sun JDK 1.6.0 03 32Bit\033[0m "
}


#
#	If 32 bit machine run following...
#
if [ "${M_TYPE}" == "32" ]
then
        if [ "${JAVA_ID}" = "" ]
         then
            print_32bit_jdk
            read -p "> " answer
         else
            answer=${JAVA_ID}
        fi

	JAVA_HOME=/
	case $answer in
		1|4) JAVA_HOME=/export/utils/java/j2sdk1.4.2_16;;        
		2) JAVA_HOME=/export/utils/java/j2sdk1.4.2_10;;        
		3) JAVA_HOME=/export/utils/java/j2sdk1.4.2_12;;        
		11) JAVA_HOME=/export/utils/java/jdk1.5.0_12;;
		12) JAVA_HOME=/export/utils/java/jdk1.5.0_13;;
		13) JAVA_HOME=/export/utils/java/jdk1.5.0_16;;
		14) JAVA_HOME=/export/utils/java/jdk1.5.0_17;;
		10|15) JAVA_HOME=/export/utils/java/jdk1.5.0_19;;
		21) JAVA_HOME=/export/utils/java/jdk1.6.0_14;;
		22) JAVA_HOME=/export/utils/java/jdk1.6.0_17;;
		20|23) JAVA_HOME=/export/utils/java/jdk1.6.0_18;;
		30|32) JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.5.0_12;;
		31) JAVA_HOME=/export/utils/java/jrockit-R27.2.0-jdk1.6.0-32bit;;
		40|43) JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.6.0_02;;
		41) JAVA_HOME=/export/utils/java/jrockit-R27.1.0-jdk1.6.0;;
		42) JAVA_HOME=/export/utils/java/jrockit-R27.2.0-jdk1.6.0-32bit;;
        	31) JAVA_HOME=/export/utils/java/jrockit-R26.0.0-jdk1.5.0_04;;
		50|52) JAVA_HOME=/export/utils/java/IBMJava2-142;;
		51) JAVA_HOME=/export/utils/java/IBMJava2-142_32Bit;;
		60|61) JAVA_HOME=/export/utils/java/ibm-java2-1.5-i386-50;;
		72) JAVA_HOME=/export/utils/java/jdk1.7.0_b78;;

	esac
	
elif [ "${M_TYPE}" == "64" ] 
	then
#
#		64Bit 
#
	if [ "${JAVA_ID}" = "" ]
         then
	    print_all_jdk	
            read -p "> " answer
         else
            answer=${JAVA_ID}
        fi
	JAVA_HOME=/
	case $answer in
# --------------------------------   Sun 1.4 
		1|5) JAVA_HOME=/export/utils/java/j2sdk1.4.2_16;;        
		2) JAVA_HOME=/export/utils/java/j2sdk1.4.2_10;;        
		3) JAVA_HOME=/export/utils/java/j2sdk1.4.2_12;;        
# --------------------------------   Sun 1.5 
		10|16) JAVA_HOME=/export/utils/java/jdk1.5.0_22-64bit;;
		11) JAVA_HOME=/export/utils/java/jdk1.5.0_12;;
		12) JAVA_HOME=/export/utils/java/jdk1.5.0_13;;
		12a) JAVA_HOME=/export/utils/java/jdk1.5.0_13-64Bit;;
		13) JAVA_HOME=/export/utils/java/jdk1.5.0_16-64bit;;
		13a) JAVA_HOME=/export/utils/java/jdk1.5.0_16;;
		14) JAVA_HOME=/export/utils/java/jdk1.5.0_17-64bit;;
		14a) JAVA_HOME=/export/utils/java/jdk1.5.0_17;;
		15a) JAVA_HOME=/export/utils/java/jdk1.5.0_19;;
# --------------------------------   Sun 1.6 
		20|29) JAVA_HOME=/export/utils/java/jdk1.6.0_43-64Bit;;
		#21) JAVA_HOME=/export/utils/java/jdk1.6.0_37-64Bit;;
		21) JAVA_HOME=/export/utils/java/jdk1.6.0_23-64Bit;;
		22) JAVA_HOME=/export/utils/java/jdk1.6.0_24-64Bit;;
		23) JAVA_HOME=/export/utils/java/jdk1.6.0_25-64Bit;;
		24) JAVA_HOME=/export/utils/java/jdk1.6.0_26-64Bit;;
		25) JAVA_HOME=/export/utils/java/jdk1.6.0_27-64Bit;;
		26) JAVA_HOME=/export/utils/java/jdk1.6.0_30-64Bit;;
		27) JAVA_HOME=/export/utils/java/jdk1.6.0_31-64Bit;;
		28) JAVA_HOME=/export/utils/java/jdk1.6.0_37-64Bit;;
		29) JAVA_HOME=/export/utils/java/jdk1.6.0_43-64Bit;;
# --------------------------------   Sun 7.0
		70|75) JAVA_HOME=/export/utils/java/jdk1.7.0_45-64Bit;;
		71) JAVA_HOME=/export/utils/java/jdk1.7.0_09-64Bit;;
		72) JAVA_HOME=/export/utils/java/jdk1.7.0_13-64Bit;;
		73) JAVA_HOME=/export/utils/java/jdk1.7.0_17-64Bit;;
		74) JAVA_HOME=/export/utils/java/jdk1.7.0_21-64Bit;;
# --------------------------------   Jrockit 1.5 
		30|32)  JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.5.0_12-64Bit;;
		31)  JAVA_HOME=/export/utils/java/jrockit-R26.0.0-jdk1.5.0_04;;
		32a)  JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.5.0_12;;
# --------------------------------   Jrockit  1.6
		40|44) JAVA_HOME=/export/utils/java/jrockit-jdk1.6.0_31-R28.2.3-4.1.0-64Bit;;
		41) JAVA_HOME=/export/utils/java/jrockit-R27.2.0-jdk1.6.0_64bit;; 
		41a) JAVA_HOME=/export/utils/java/jrockit-R27.2.0-jdk1.6.0-32bit;;
		42) JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.6.0_02-64Bit;;
		42a) JAVA_HOME=/export/utils/java/jrockit-R27.4.0-jdk1.6.0_02;;
		43) JAVA_HOME=/export/utils/java/jrrt-4.0.1-1.6.0-64bit;;
# --------------------------------   IBM 1.6
		60) JAVA_HOME=/export/utils/java/java-ibm1.6-x86_64-60;;
# --------------------------------   IBM 1.7
		65|68) JAVA_HOME=/export/utils/java/java-ibm1.7-x86_64-70-SR6;;
		66) JAVA_HOME=/export/utils/java/java-ibm1.7-x86_64-70-SR3;;
		67) JAVA_HOME=/export/utils/java/java-ibm1.7-x86_64-70-SR5;;
		68) JAVA_HOME=/export/utils/java/java-ibm1.7-x86_64-70-SR6;;



		99) JAVA_HOME=/opt/zingLX-jdk1.6.0_29-5.1.4.0-13;;

	esac
elif [ "${M_TYPE}" == "ppc64" ]
        then
#
#            PPC   64Bit
#
        if [ "${JAVA_ID}" = "" ]
         then
            print_ppc64
            read -p "> " answer
         else
            answer=${JAVA_ID}
        fi
        JAVA_HOME=/
        case $answer in
# --------------------------------   Sun 1.4
                1) JAVA_HOME=/export/utils/java/IBMJava2-ppc64-142;;
                1a) JAVA_HOME=/export/utils/java/IBMJava2-ppc-142;;
# --------------------------------   Sun 1.5
                10) JAVA_HOME=/export/utils/java/ibm-java2-ppc64-50 ;;
                10a) JAVA_HOME=/export/utils/java/ibm-java2-ppc-50 ;;
# --------------------------------   Sun 1.6
                20) JAVA_HOME=/export/utils/java/ibm-java-ppc64-60;;
                20a) JAVA_HOME=/export/utils/java/ibm-java-ppc-60;;
	esac
else 
	echo -e "Your system is not supported,\n\tPlease contact System: 6711"

fi

export PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME PATH

