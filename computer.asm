assume cs:code,ss:stack
stack segment
    db 128 dup (0)
stack ends
code segment
start:
    mov ax,stack
    mov ss,ax
    mov sp,128
    
    call copy_boot
    
    ;����CS:IPΪ0:7e00h
    mov ax,0
    push ax
    mov ax,7e00h
    push ax
    retf
    
    mov ax,4c00h
    int 21h
;org 7e00h
;��������
boot:
    jmp boot_begin
    func0    db 'Hk_Mayfly----XIUXIUXIU~',0
    func1    db '1) reset pc',0
    func2    db '2) start system',0
    func3    db '3) clock',0
    func4    db '4) set clock',0
    ;����õ����Ǳ�ŵ����λ�ã�+7e00h�õ��ľ���λ��
    func_pos    dw offset func0-offset boot+7e00h
                dw offset func1-offset boot+7e00h
                dw offset func2-offset boot+7e00h
                dw offset func3-offset boot+7e00h
                dw offset func4-offset boot+7e00h
    time    db 'YY/MM/DD hh:mm:ss',0
    cmos    db 9,8,7,4,2,0
    clock1    db 'F1----change the color        ESC----return menu',0
    clock2    db 'Please input Date and Time,(YY MM DD hh mm ss):',0
    change    db 12 dup (0),0

boot_begin:
    call init_boot
    call cls_screen
    call show_menu 
    jmp choose
    mov ax,4c00h
    int 21h

choose:
    call clear_kb_buffer
    ;��ȡ��������Ĳ�������ת�����ں���
    mov ah,0
    int 16h
    cmp al,'1'
    je choose_func1
    cmp al,'2'
    je choose_func2
    cmp al,'3'
    je choose_func3
    cmp al,'4'
    je choose_func4
    
    jmp choose

;�������ᵽ�ˣ���������뵽ffff:0��ִ��ָ��
;������Ҳ���԰��������Ϊ����ת��ffff:0ִ��ָ��
;������������jmp dword��ת��ffff:0��ַ��ģ������
choose_func1:
    mov bx,0ffffh
    push bx
    mov bx,0
    push bx
    retf
    
    jmp choose

;���ж��������еĲ���ϵͳ�������ǵ���int 19������Ϊ�˷����ֱ��д�ɺ�����
choose_func2:
    mov bx,0
    mov es,bx
    mov bx,7c00h
    
    mov al,1;������
    mov ch,0
    mov cl,1;����
    mov dl,80h
    mov dh,0
    mov ah,2;��ȡ
    int 13h
    
    mov bx,0
    push bx
    mov bx,7c00h
    push bx
    retf
    
    jmp choose

;��ȡʱ��
choose_func3:
    call show_time
    
    jmp choose

show_time:
    call init_boot
    call cls_screen
    ;��ʾ������Ϣ
    mov si,offset clock1-offset boot+7e00h
    mov di,160*14+10*2;��14��10����ʾ
    call show_line
show_time_start:
    ;��ȡʱ����Ϣ������ʾ����time�е�δ֪�ַ��滻Ϊ��ǰʱ�䣩
    call get_time_info
    mov di,160*10+30*2;��Ļ��ʾ��ƫ�Ƶ�ַ
    mov si,offset time-offset boot+7e00h;time��ŵ�ƫ�Ƶ�ַ
    call show_line
    
    ;��ȡ���̻�����������
    mov ah,1
    int 16h
    ;û�����ݾ�����show_time_start
    jz show_time_start
    ;�ж��Ƿ���F1
    cmp ah,3bh
    je change_color
    ;�ж��Ƿ���ESC
    cmp ah,1
    je Return_Main
    ;�����ݣ����������õļ����жϣ����
    cmp al,0
    jne clear_kb_buffer2
    ;���ؿ�ʼ���ظ�֮ǰ�Ĳ������ﵽˢ��ʱ���Ч����
    jmp show_time_start

change_color:
    call change_color_show
clear_kb_buffer2:
    call clear_kb_buffer
    jmp show_time_start
Return_Main:
    ;���ص���ʼ�����´�ӡ�˵�
    jmp boot_begin
    ret

choose_func4:
    call set_time
    jmp boot_begin
    
set_time:
    call init_boot
    call cls_screen
    call clear_stack
    
    ;������ʾ��Ϣ��ʾλ��
    mov di,160*10+13*2
    mov si,offset clock2-offset boot+7e00h
    call show_line
    ;��ʾ�޸ĺ�change�е�����
    mov di,160*12+26*2
    mov si,offset change-offset boot+7e00h
    call show_line
    
    call get_string

get_string:
    mov si,offset change - offset boot + 07e00H
    mov bx,0
getstring:
    ;��ȡ���������ʱ����Ϣ
    mov ah,0
    int 16h
    
    ;�����ʱ��Ϊ����0~9
    cmp al,'0'
    jb error_input
    cmp al,'9'
    ja error_input
    ;�����������ʱ���ַ���ջ
    call char_push
    ;���ܳ������������
    cmp bx,12
    ja press_ENTER
    mov di,160*12+26*2
    call show_line
    jmp getstring
error_input:
    ;�ж��ǲ��ǰ����˸��س���
    cmp ah,0eh
    je press_BS
    cmp ah,1ch
    je press_ENTER

    jmp getstring
;���»س�
press_BS:
    call char_pop
    mov di,160*12+26*2
    call show_line
    jmp getstring
;����enter���˳�
press_ENTER:
    ret

char_push:
    ;ֻ���������12������
    cmp bx,12
    ja char_push_end
    ;����ֵ�ƶ�����Ӧλ��
    mov ds:[si+bx],al
    inc bx;��ʾ���������˶��ٸ��ַ�
char_push_end:
    ret

char_pop:
    ;�ж��Ƿ�����������ʱ�����ֵ��û�о��൱��ɾ����
    cmp bx,0
    je char_pop_end
    ;�������Ǻ��滻���൱��ɾ��
    dec bx
    mov byte ptr ds:[si+bx],'*'
char_pop_end:
    ret

clear_stack:
    push bx
    push cx
    
    mov bx,offset change-offset boot+7e00h
    mov cx,12
cls_stack:
    ;�滻change��������
    mov byte ptr ds:[bx],'*'
    inc bx
    loop cls_stack
    
    pop cx
    pop bx
    ret
    

;��ȡʱ��
get_time_info:
    ;��cmos ram��ȡ�����գ�ʱ����6������
    mov cx,6
    ;��ȡ��ŵ�Ԫ��ַ
    mov bx,offset cmos - offset boot + 7e00H
    ;ͨ���滻����ʾ
    mov si,offset time - offset boot + 7e00H
next_point:   
    push cx
    ;��ȡ��Ԫ��
    mov al,ds:[bx]
    ;��70h�˿�д��Ҫ���ʵĵ�Ԫ��ַ������71h�˿ڶ�ȡ����
    out 70H,al
    in al,71H
    ;����4λ��ȡʮλ
    mov ah,al
    mov cl,4
    shr al,cl
    and ah,00001111b
    ;��BCD��ת��ΪASCII��
    add ax,3030H
     ;д��time��
    mov word ptr ds:[si],ax
    ;��һ��Ԫ��
    inc bx
    ;ÿ������֮����붼��3
    add si,3
    pop cx
    loop next_point
    ret

;�ı���ɫ
change_color_show:
    push bx
    push cx
 
    mov cx,2000
    mov bx,1
next:
    ;����ֵ+1���ı���ɫ
    add byte ptr es:[bx],1
    ;������������ɫ����ֵ(0~111h)ʱ������ֵ����
    cmp byte ptr es:[bx],00001000b
    jne change_end
    ;��Ϊ�����Ǻ�ɫ������������ɫ�Ͳ����óɺ�ɫ��
    mov byte ptr es:[bx],1
change_end:
    add bx,2
    loop next
 
    pop cx
    pop bx
    ret

clear_kb_buffer:
    ;1�ų������������̻������Ƿ�������
    ;����еĻ�ZF!=0��û�У�ZF=0
    mov ah,1
    int 16h
    ;ͨ��ZF�жϼ����������Ƿ������ݣ�û�о�����
    jz clear_kb_bf_end
    mov ah,0
    int 16h
    jmp clear_kb_buffer
clear_kb_bf_end:
    ret

init_boot:
    ;�������ã�ע�⣺�����ֱ�Ӷ�ַ��Ĭ�϶ε�ַ��CS
    ;������ת�Ƶ�7c00hʱ��������CSֵδ�����ı䣬
    ;������Ҫ����ָ���ε�ַ
    mov bx,0b800h
    mov es,bx
    mov bx,0
    mov ds,bx
    ret
    
;����
cls_screen:
    mov bx,0
    mov cx,2000
    mov dl,' '
    mov dh,2;����Ϊ��ɫ�������õĻ�����������ʾ�˵�ʱ������ͱ�����ɫ��ͬ
s:    mov es:[bx],dx
    add bx,2
    loop s
sret:
    ret

;չʾ����
show_menu:
    ;��10�У�30����ʾ�˵�
    mov di,160*10+30*2
    ;������ֱ�Ӷ�ַ��ľ���λ��
    mov bx,offset func_pos-offset boot+7e00h
    ;�˵���5��
    mov cx,5
s1:
    ;�����൱����ѭ����ÿ��һ��
    ;��ȡfunc_pos��ÿ�еı���λ�õ�ƫ�Ƶ�ַ
    mov si,ds:[bx]
    ;������ѭ�����������һ�е�ÿ���ַ�
    call show_line
    ;��һ��ƫ�Ƶ�ַ
    add bx,2
    ;��һ����ʾ
    add di,160
    loop s1
    ret
    
show_line:
    push ax
    push di
    push si
show_line_start:
    ;��ȡ��һ�еĵ�si+1���ַ�
    mov al,ds:[si]
    ;�ж��Ƿ�ĩβ
    cmp al,0
    je show_line_end
    ;�����ַ�����ʾ������
    mov es:[di],al
    add di,2
    inc si
    jmp show_line_start
show_line_end:
    pop si
    pop di
    pop ax
    ret

boot_end:nop

;ת����������
copy_boot:
    ;���������򴢴浽ָ��λ��
    mov ax,0
    mov es,ax
    mov di,7e00h
    
    mov ax,cs
    mov ds,ax
    mov si,offset boot
    mov cx,offset boot_end-offset boot
    cld
    rep movsb
    
    ret

code ends
end start
