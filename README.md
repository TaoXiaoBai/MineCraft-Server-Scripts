# Modpack 服务器启动脚本

   只是一个Minecraft-Forge 服务器安装/启动脚本
   （Readme修改中）



<br>

<br>

<br>


## 脚本说明
#### 通过Batch/Script来安装/运行modpack服务器，适用于Windows和Linux（Bash）. 
   这些脚本将获取适当的Forge安装程序并进行安装它，这也将安装Mojang的发行版的Minecraft二进制文件和所需的库。

   在安装了Forge/Minecraft之后，同一个脚本将作为启动器来启动服务器，同时还具有崩溃后自动重启的功能。不需要单独的脚本）
   它还能适应平稳过渡到新版本的Forge *即使是在已经设置好的现有服务器上*
   如果安装的Forge版本与settings.cfg中提供的版本不同，该脚本将删除旧的Forge，并重新下载并安装指定的版本。脚本也会执行非常多的基本检查，比如检查是否安装了正确的Java版本，检查EULA.txt是否已经更新。

   所有相关的设置都在易于访问的 "settings.cfg "文件中；Modpack的作者可以指定他们的包的Minecraft和Forge版本，服主可以根据需要指定JVM args和RAM分配。


<br>

<br>

<br>


# 如何使用？

#### 不要修改`ServerStart.bat`或`ServerStart.sh`
#### 所有的设置都在`settings.cfg`中修改

Windows: **`ServerStart.Bat`** *(Run/Double-Click)*  
Linux: **`bash ServerStart.sh`** *(must be bash, not shell/sh)*

#### 参数
| Setting   | Description                |
| ----------|----------------------------|
| -i, --install, install | 只运行脚本的安装部分，安装完成后，服务器不会自动启动。|
| -a, --auto | 跳过用户输入阶段，使用默认值代替。 |

#### 如果是远程控制运行的服务器，则可以使用以下命令使其即使在关闭终端时也保持运行:
 ```
 nohup ./ServerStart.sh -a &>/dev/null &
 ```
________________   

### settings.cfg   
正确的格式对于正确加载非常重要。
* `SETTING=VALUE`。
* 等号周围没有空格
* 每行一个设置


| Setting   | Description                | Example Value | 
| ----------|----------------------------| :------------:|
| **MAX_RAM**      | 允许JVM分配给服务器的最大内存是多少？ | `5G` |
| **JAVA_ARGS**      | 提供的默认值对大多数人来说应该是最好的，但如果需要的话，可以进行编辑。 | *See Below* |
| **CRASH_COUNT** | 连续崩溃的最大次数，每次崩溃发生的秒数。如果达到最大值，脚本将退出。这是为了防止服务器在出现严重问题时的垃圾重启. | `8` |
| **CRASH_TIMER** | The number of seconds to consider a crash within to be "consecutive" | `600` |
| **RUN_FROM_BAD_FOLDER** | 脚本不会从 "temp "文件夹或 "system "文件夹运行。如果你想强制允许这样做，请将值改为 `1` | `0` | 
| **IGNORE_OFFLINE** | 如果找不到互联网的连接，脚本将无法运行。如果你想强制允许(即只为本地/局域网运行服务器)，则设置为`1`。但请注意，它至少需要互联网连接来执行Forge文件的初始下载/安装。 | `0` |
| **IGNORE_JAVA_CHECK** | 默认情况下，如果找不到64位的Java 1.8或1.9，脚本会停止/出错。一些整合包可能会在少于4G或内存较旧的1.7java上运行，如果你想使用较旧的版本或仅限于32位的操作系统，将此设置为`1`。如果你想使用旧的版本或仅限于32位操作系统，将此设置为`1`将使脚本继续运行。 | `0` | 
| **USE_SPONGE** | 大部分是不被支持和实验性的。如果设置为`1`，脚本将尝试启动SpongeBootstrap，但只有在启动器存在且SpongeForge在Mods文件夹中时才会启动。这也不会下载/设置所需的文件，只是使用它们启动。**Sponge 可能会导致未记录的错误和冲突，因此它的使用很少被modpack开发者支持。使用时请自行承担风险，并且只有在您知道自己在做什么的情况下才能使用** | `0` |
| **HIGH_CPU_PRIORITY** | 这将尝试以比 "normal "更高的优先级来启动Java进程。这应该不会对主机产生重大的负面影响，但如果它造成冲突或占用太多CPU时间，你可以尝试禁用。*Linux的实现仍然是WIP（TODO）*。| `1` |
| **MODPACK_NAME** | 在脚本运行时添加描述的包名，不需要引号，可以包含空格。技术上可以很长，但如果简短/精炼，效果会更好) | `整合包名称` |
| **DEFAULT_WORLD_TYPE** | 允许更改并使用的世界类型.  | `BIOMESOP` |
| **MCVER** | 使用的Minecraft版本。通常由整合包开发者在发布前设置，一般用户无需更改。版本名称必须是完整或准确的，并与Forge网站上的版本相匹配（即`1.10`与`1.10.2`不同）| `1.12.2` |
| **FORGEVER** | 目标Forge版本。通常由整合包开发者在发布前设置，一般用户无需更改。需要完整的版本，并与Forge的网站完全匹配。(即`2254`将无法工作，但`12.18.3.2254`可以) | `12.18.3.2281` | 
| **FORGEURL** | 直接指向一个Forge "安装程序 "jar的网址，这主要是为了调试，但如果指定了一个URL，这个链接的Forge安装程序将被下载，而不考虑之前的设置.\*   | `DISABLE` |


\**NOTE: 另一个调试/绕过选项是让modpack制作者打包并重新发布与他们所需版本相匹配Forge安装程序，只要其名称符合`forge-<MinecraftVersion>-<ForgeVersion>-installer.jar `如果包含，则不需要先下载。.*  

<br>

<br>

<br>


## 可选的一些Java参数

   可选择的Java参数

   Java可以通过args进行调整，有时可以改善Minecraft的性能，超过默认args值（没有启动选项），特别是对于1.12+和更大的整合包，如All The Mods等。

<br>


______________________________
**BASIC**  
这些基本设置建议用于任何modpack的一般用途。
   ```
   -d64 -server -XX:+AggressiveOpts -XX:ParallelGCThreads=3 -XX:+UseConcMarkSweepGC -XX:+UnlockExperimentalVMOptions -XX:+UseParNewGC -XX:+ExplicitGCInvokesConcurrent -XX:MaxGCPauseMillis=10 -XX:GCPauseIntervalMillis=50 -XX:+UseFastAccessorMethods -XX:+OptimizeStringConcat -XX:NewSize=84m -XX:+UseAdaptiveGCBoundary -XX:NewRatio=3 -Dfml.readTimeout=90 -Ddeployment.trace=true -Ddeployment.log=true -Ddeployment.trace.level=all -Dfml.debugNetworkHandshake=true -Dfml.badPacketCounter=10
   ```   


<br>
   
______________________________
关于JVM args的好与不好，有很多意见，这些意见因人而异，因时而异。上面的设置是基于[this great discussion/explanation](https://www.reddit.com/r/feedthebeast/comments/5jhuk9/modded_mc_and_memory_usage_a_history_with_a/)，作者是EnderIO的首席开发人员和Forge项目的杰出贡献者CPW。



<br>

<br>

<br>


# 特别鸣谢
   本项目是以All The Mods Team的项目Server-Scripts进行翻译而已，感谢All The Mods Team的的付出



<br>
<br>
<br>
<br>


_____________________

<br>

<br>

<br>


# Custom License
   请查看License.md
____________________________
## DISCLAIMERS

"All The Mods Team" and me is not affiliated with "Mojang," "Oracle," "Curse," "Twitch," "Sponge," "Forge" or any other entity (or entity owning a referenced product) potentially mentioned in this document or relevant source code for this Software. The use of their names and/or trademarks is strictly circumstantial and assumed fair-use. All credit for their respective works, software, branding, copyrights and/or trademarks belongs entirely to them as original owners/licensers.

```
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```


_______________________________


<br>
<br>
<br>
<br>
<p align="center">
  <img src="https://i1.wp.com/allthepacks.com/wp-content/uploads/2017/01/Abyus4d.png" alt="All The Mods" width="400" height="400">
</p>
<br>

