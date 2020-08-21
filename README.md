# assembly_computer
## 1.0 要求和功能

 该程序的功能如下: 

1. 列出功能选项,让用户通过键盘进行选择,界面如下 

>   1) reset pc     ;重新启动计算机 
>
>   2) start system   ;引导现有的操作系统 
>
>   3) clock       ;进入时钟程序 
>
>   4) set clock     ;设置时间 

2. 用户输入"1"后重新启动计算机(提示:考虑`ffff:0单元`) 

3. 用户输入"2"后引导现有的操作系统(提示:考虑硬盘C的0道0面1扇区)。 

4. 用户输入"3"后,执行动态显示当前日期、时间的程序。 

显示格式如下:`年/月/日 时:分:秒` 

进入此项功能后,一直动态显示当前的时间,在屏幕上将出现时间按秒变化的效果(提示: 循环读取CMOS)。 

当按下F1键后,改变显示颜色;按下Esc键后,返回到主选单(提示:利用键盘中断)。 

5. 用户输入"4"后可更改当前的日期、时间,更改后返回到主选单(提示:输入字符串)。

## 2.0 功能实现
### 2.1 主界面
![](https://github.com/hkmayfly/assembly_computer/blob/master/p1.png)

### 2.2 重启
![](https://github.com/hkmayfly/assembly_computer/blob/master/p2.png)

### 2.3 动态显示时间
![](https://github.com/hkmayfly/assembly_computer/blob/master/p3.png)

### 2.4 字体颜色
![](https://github.com/hkmayfly/assembly_computer/blob/master/p4.png)

### 2.5 设置时间
![](https://github.com/hkmayfly/assembly_computer/blob/master/5.png)
