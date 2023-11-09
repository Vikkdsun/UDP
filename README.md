# UDP🎈
A UDP project of Verilog.

## 一个UDP以太网协议栈的项目

文件中的代码采用（中式🤣）英文注释，为了防止VIVADO运行成乱码。
### MAC层
![image](https://github.com/Vikkdsun/UDP/assets/114153159/c50a3a43-966b-4c20-a68a-ceabd903f2fd)

图中前导码应该为8B，6个55，一个D5。

无论发送还是接收，目的MAC永远是本FPGA通信的另一个设备，源MAC为本FPGA。

### IP层
![image](https://github.com/Vikkdsun/UDP/assets/114153159/38eea051-8068-448e-bd49-fe060411cfd1)

图中有两个错误：1： 标志表示非分片应该是第二位为1 2： 版本处ipv4应该是0100。

总长度是IP头加上数据长度的，所以在接收时要把20B长度的IP头减下去传给UDP或者ICMP层。

### ARP层
![image](https://github.com/Vikkdsun/UDP/assets/114153159/4af59e2e-2849-4cf0-8a1d-9c4fecaff7ee)

![image](https://github.com/Vikkdsun/UDP/assets/114153159/7d0f6fcc-7f20-4852-a188-66bc7c47325e)

在接收时，接收发送方的MAC和IP，以及查看操作类型，为1表示请求，那么发送时要做回复。一般情况下，初次通信时，图中的目标MAC和IP全为0，等到FPGA发送时，把MAC和IP填上去组包发送。

此外在接收时接收到的目的IP，并且报文表示请求，发送一个回复信号和这个目的IP给发送端，发送端接收这个目的IP如果是FPGA的，那么把本地MAC和IP在回复时发上去。

### UDP层
![image](https://github.com/Vikkdsun/UDP/assets/114153159/3d64292f-648a-4f4d-9dd4-bba9266b352d)


没啥好说的，长度这里和IP一样。

### ICMP层
![image](https://github.com/Vikkdsun/UDP/assets/114153159/fa27c8b5-b3a0-4a72-8fd3-5b9f4283b87f)


类型：8=请求 0=回复 标识符： windows固定为1  序号：发一次请求 增加1 同时请求和回复序号相同。

### 更新log

目前已更新RX部分，还有TX部分、仲裁、ARP表、GMII2RGMII等。

2023/11/9 10:57  ：  更新了MAC_tx模块，已知和常规操作比慢了一个周期，还在找优化策略。

验证后发现并不延后，正常时序。

2023/11/9 17:46  :  更新了IP_tx模块，该模块比MAC_tx模块简单，但是输出有两组端口，一组交给MAC，一组交给ARP。

等待更新...
