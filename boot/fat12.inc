; BSD License, 2017, Mega Show
; FileName: fat12.inc
; Description: Define information of FAT12
;==========================================

BS_OEMName	    db    "TOSX-OEM"	; OEM String, 必须 8 个字节
BPB_BytsPerSec	dw    512		    ; 每扇区字节数
BPB_SecPerClus	db    1		        ; 每簇多少扇区
BPB_RsvdSecCnt	dw    1	        	; Boot记录占用多少扇区
BPB_NumFATs	    db    2		        ; FAT表数
BPB_RootEntCnt	dw    224		    ; 根目录文件数最大值
BPB_TotSec16	dw    2880		    ; RolSec16, 逻辑扇区总数
BPB_Media	    db    0f0h		    ; 媒体描述符(介质种类: 移动介质)
BPB_FATSz16	    dw    9		        ; FATSz16分区表占用扇区数
BPB_SecPerTrk	dw    18		    ; 每磁道扇区数
BPB_NumHeads	dw    2	        	; 磁头数(面数)
BPB_HiddSec	    dd    0     		; 隐藏扇区数
BPB_TotSec32	dd    0		        ; 如果 wTotalSectorCount 是 0 由这个值记录扇区数(OS67为2880)
BS_DrvNum	    db    0		        ; 中断 13 的驱动器号
BS_Reserved1	db    0		        ; 保留值
BS_BootSig	    db    029h		    ; BootSig扩展引导标记(29h)
BS_VolID	    dd    0		        ; 卷序列号(OS67为0xffffffff)
BS_VolLab	    db    "TOSX-FAT12!" ; 卷标, 必须 11 个字节
BS_FileSysType	db    "FS-FAT12"	; 文件系统类型, 必须 8个字节
