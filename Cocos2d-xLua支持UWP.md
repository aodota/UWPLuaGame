Cocos2d-x Lua支持UWP
==============================
> 前言：UWP是微软搞的一个Windows通用平台，只要运行Win10的平板、电脑、Xbox以及以后微软推出的各种设备都能运行的一套应用框架。
> 听起来十分诱人！游戏是应用中最重要的一个类别，我们广大开发者当然希望能分享这个市场。可是`Cocos2d-x Lua`对`UWP`的> 支持为零，官方明确不在此投入了，作为开发者十分伤心啊！那只能我们广大开发者自己动手了，下面是我实践的记录，最终是成功运行了Lua代码，但离跑完整的游戏还是有一定距离，特分享出来，希望借助开源的力量大家一起研究！

### 一、环境介绍

基于`cocos2d-x 3.10`版本，之前的版本对UWP的支持很差就不考虑了。我的思路是基于官方提供的`cpp`版本修改添加`lua`的支持

### 二、改造`libluacocos2d`为`UWP`工程

我的思路是基于`win32`版本修改，模仿`win10`的`libcocos2d`。比较核心的修改有：

- 修改项目依赖

依赖的`libcocos2d`修改为`win10`工程的
```xml
<ItemGroup>
    <ProjectReference Include="..\..\..\2d\libcocos2d_win10\libcocos2d.vcxproj">
      <Project>{07c2895d-720c-487d-b7b4-12c293ea533f}</Project>
    </ProjectReference>
</ItemGroup>
```

- 重新定义项目的基本属性

```xml
<PropertyGroup Label="Globals">
	<ProjectGuid>{9F2D6CE6-C893-4400-B50C-6DB70CC2562F}</ProjectGuid>
	<Keyword>DynamicLibrary</Keyword>
	<ProjectName>libluacocos2d</ProjectName>
	<RootNamespace>libluacocos2d</RootNamespace>
	<DefaultLanguage>en-US</DefaultLanguage>
	<MinimumVisualStudioVersion>14.0</MinimumVisualStudioVersion>
	<AppContainerApplication>true</AppContainerApplication>
	<ApplicationType>Windows Store</ApplicationType>
	<ApplicationTypeRevision>8.2</ApplicationTypeRevision>
	<WindowsTargetPlatformVersion>10.0.14393.0</WindowsTargetPlatformVersion>
	<WindowsTargetPlatformMinVersion>10.0.14393.0</WindowsTargetPlatformMinVersion>
</PropertyGroup>
```

- 修改`cocos2d_headers.props`成`win10`版本

我建立一个`win10`的`cocos2d_headers_win10.props`内容如下：
``` xml
<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <ImportGroup Label="PropertySheets" />
  <PropertyGroup Label="UserMacros">
    <EngineRoot>$(MSBuildThisFileDirectory)..\..\</EngineRoot>
  </PropertyGroup>
  <PropertyGroup />
  <ItemDefinitionGroup>
    <ClCompile>
      <AdditionalIncludeDirectories>$(EngineRoot)cocos;$(EngineRoot)cocos/editor-support;$(EngineRoot)cocos\platform\winrt;$(EngineRoot)external\glfw3\include\$(COCOS2D_PLATFORM);$(EngineRoot)external\$(COCOS2D_PLATFORM)-specific\gles\include\OGLES;$(EngineRoot)external\freetype2\include\$(COCOS2D_PLATFORM)\freetype2;$(EngineRoot)external\freetype2\include\$(COCOS2D_PLATFORM)\;$(EngineRoot)external</AdditionalIncludeDirectories>
      <PreprocessorDefinitions>WINRT;_VARIADIC_MAX=10;NOMINMAX;GL_GLEXT_PROTOTYPES;_CRT_SECURE_NO_WARNINGS;_SCL_SECURE_NO_WARNINGS;_UNICODE;UNICODE;RAPIDJSON_ENDIAN=RAPIDJSON_LITTLEENDIAN;_USRJSSTATIC;%(PreprocessorDefinitions)</PreprocessorDefinitions>
      <CompileAsWinRT>true</CompileAsWinRT>
      <MultiProcessorCompilation>true</MultiProcessorCompilation>
      <MinimalRebuild>false</MinimalRebuild>
      <DebugInformationFormat>OldStyle</DebugInformationFormat>
      <DisableSpecificWarnings>4056;4244;4251;4756;4453;28204;4099;</DisableSpecificWarnings>
    </ClCompile>
    <ProjectReference>
      <UseLibraryDependencyInputs>false</UseLibraryDependencyInputs>
    </ProjectReference>
  </ItemDefinitionGroup>
  <ItemGroup>
    <BuildMacro Include="EngineRoot">
      <Value>$(EngineRoot)</Value>
      <EnvironmentVariable>true</EnvironmentVariable>
    </BuildMacro>
  </ItemGroup>
</Project>
```

- 修改头文件输入

`angle`的依赖修改为`win10`版本

``` xml
<AdditionalIncludeDirectories>$(EngineRoot);$(EngineRoot)cocos\2d;$(EngineRoot)cocos\base;$(EngineRoot)cocos\3d;$(EngineRoot)cocos\physics;$(EngineRoot)cocos\physics3d;$(EngineRoot)cocos\audio\include;$(EngineRoot)cocos\ui;$(EngineRoot)cocos\navmesh;$(EngineRoot)external;$(EngineRoot)external\lua;$(EngineRoot)external\lua\lua;$(EngineRoot)external\lua\tolua;$(EngineRoot)external\lua\luajit\include;$(EngineRoot)external\libwebsockets\win10\include;$(EngineRoot)extensions;$(EngineRoot)cocos\editor-support;$(EngineRoot)cocos\editor-support\cocostudio;$(EngineRoot)cocos\editor-support\cocostudio\ActionTimeline;$(EngineRoot)cocos\editor-support\spine;$(EngineRoot)cocos\editor-support\cocosbuilder;$(EngineRoot)cocos\scripting\lua-bindings\manual;$(EngineRoot)cocos\scripting\lua-bindings\auto;$(EngineRoot)cocos\scripting\lua-bindings\manual\extension;$(EngineRoot)cocos\scripting\lua-bindings\manual\cocostudio;$(EngineRoot)cocos\scripting\lua-bindings\manual\ui;$(EngineRoot)cocos\scripting\lua-bindings\manual\cocos2d;$(EngineRoot)cocos\scripting\lua-bindings\manual\navmesh;$(EngineRoot)external\win10-specific\angle\include;$(EngineRoot)cocos\platform;%(AdditionalIncludeDirectories)</AdditionalIncludeDirectories>
```

- 宏定义修改

比较重要的是添加`_USRLUASTATIC`: 解决dllimport编译报错

``` xml
<PreprocessorDefinitions>_USRDLL;_LIB;COCOS2DXWIN32_EXPORTS;_USE3DDLL;_EXPORT_DLL_;_USRSTUDIODLL;_USREXDLL;_USEGUIDLL;_USRLUASTATIC;_DEBUG;COCOS2D_DEBUG=1;_CRT_SECURE_NO_WARNINGS;_WINSOCK_DEPRECATED_NO_WARNINGS;%(PreprocessorDefinitions)</PreprocessorDefinitions>
```

- 对于里面的'.c'文件右键属性，如下图修改：

![](/image/cocoslua_1.png)

**这是解决：D8048	无法使用 /ZW 选项编译 C 文件**

但项目整体是开启`使用Windows运行时扩展`

### 三、改造主工程，添加Lua支持

- 按照`win32`版本修改`AppDelegate.cpp`

非关键部分已省略

```C++
#include "AppDelegate.h"
#include "scripting/lua-bindings/manual/CCLuaEngine.h"
#include "scripting/lua-bindings/manual/lua_module_register.h"

bool AppDelegate::applicationDidFinishLaunching() {
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();
    if(!glview) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_MAC) || (CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
        glview = GLViewImpl::createWithRect("MyCppGame", Rect(0, 0, designResolutionSize.width, designResolutionSize.height));
#else
        glview = GLViewImpl::create("MyCppGame");
#endif
        director->setOpenGLView(glview);
    }

    // turn on display FPS
    director->setDisplayStats(true);

    // set FPS. the default value is 1.0/60 if you don't call this
    director->setAnimationInterval(1.0 / 60);

	// register lua module
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
	lua_State* L = engine->getLuaStack()->getLuaState();
	lua_module_register(L);

	LuaStack* stack = engine->getLuaStack();
	stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));

    // Set the design resolution
    //glview->setDesignResolutionSize(designResolutionSize.width, designResolutionSize.height, ResolutionPolicy::NO_BORDER);
    //Size frameSize = glview->getFrameSize();
    // if the frame's height is larger than the height of medium size.
    //if (frameSize.height > mediumResolutionSize.height)
    //{        
    //    director->setContentScaleFactor(MIN(largeResolutionSize.height/designResolutionSize.height, largeResolutionSize.width/designResolutionSize.width));
    //}
    // if the frame's height is larger than the height of small size.
    //else if (frameSize.height > smallResolutionSize.height)
    //{        
    //    director->setContentScaleFactor(MIN(mediumResolutionSize.height/designResolutionSize.height, mediumResolutionSize.width/designResolutionSize.width));
    //}
    // if the frame's height is smaller than the height of medium size.
    //else
    //{        
    //    director->setContentScaleFactor(MIN(smallResolutionSize.height/designResolutionSize.height, smallResolutionSize.width/designResolutionSize.width));
    //}

    register_all_packages();

	if (engine->executeScriptFile("src/main.lua"))
	{
		return false;
	}

    // create a scene. it's an autorelease object
    //auto scene = HelloWorld::createScene();

    // run
    //director->runWithScene(scene);

    return true;
}
```
- 修改头文件输入

``` xml
..\..\Classes;$(EngineRoot);$(EngineRoot)cocos\audio\include;$(EngineRoot)external;$(EngineRoot)external\lua;$(EngineRoot)external\lua\luajit\include;$(EngineRoot)external\lua\tolua;$(EngineRoot)extensions;$(EngineRoot)cocos\scripting\lua-bindings\manual;$(EngineRoot)cocos\scripting\lua-bindings\auto;Cocos2dEngine;Generated Files\Cocos2dEngine;%(AdditionalIncludeDirectories)
```

- 添加宏定义

```
_USRLUASTATIC;%(PreprocessorDefinitions)
```

- 关闭链接库警告

![](/image/cocoslua_2.png)

- 运行试试Lua啦

Lua代码放在`Resources\src`里面

我的项目运行效果如下：

![](/image/cocoslua_3.gif)

