import 'package:flutter/material.dart';
import '../service/service_method.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Scaffold(
        appBar: AppBar(title: Text('网络数据请求'),),
        body: FutureBuilder(
          future: getHomePageContent(),
            builder: (context, snapShort){
              if(snapShort.hasData){
                var data = json.decode(snapShort.data.toString());
                //轮播图
                List<Map> swiper = (data['data']['slides'] as List).cast();
                //网格
                List<Map> topNavigator = (data['data']['category'] as List).cast();
                //广告
                String adPicUrl = data['data']['advertesPicture']['PICTURE_ADDRESS'];
                //经理电话组件
                String leaderImageUrl = data['data']['shopInfo']['leaderImage'];
                String leaderPhone = data['data']['shopInfo']['leaderPhone'];
                //推荐商品
                List<Map> recommendList = (data['data']['recommend'] as List).cast();
                return SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      SwiperDiy(swiperDataList: swiper,),
                      TopNavigator(navigatorList: topNavigator,),
                      AdBanner(adPicUrl: adPicUrl,),
                      LeaderPhone(leaderImageUrl: leaderImageUrl, leaderPhone: leaderPhone,),
                      Recommend(recommendList: recommendList,),
                    ],
                  ),
                );
              }else{
                return Center(
                  child: Text('加载中......'),
                );
              }
            }
        )
      ),
    );
  }
}

//首页轮播图组件
class SwiperDiy extends StatelessWidget {

  final List swiperDataList;
  SwiperDiy({this.swiperDataList});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemCount: swiperDataList.length,
        itemBuilder: (context, index){
          return Image.network('${swiperDataList[index]['image']}',fit: BoxFit.fill,);
        },
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}

//网格组件
class TopNavigator extends StatelessWidget {

  final List navigatorList;
  TopNavigator({Key key, this.navigatorList}):super(key:key);

  Widget _gridViewItem(BuildContext context, item){
    return InkWell(
      onTap: (){},
      child: Column(
        children: <Widget>[
          Image.network(item['image'],width: ScreenUtil().setWidth(95),),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //这里只需要10个，为了好看而已
    if(navigatorList.length>10){
      navigatorList.removeRange(10, navigatorList.length);
    }

    return Container(
      height: ScreenUtil().setHeight(270),
      padding: EdgeInsets.all(5.0),
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item){
          return _gridViewItem(context, item);
        }).toList(),
      ),
    );
  }
}

//广告组件
class AdBanner extends StatelessWidget {

  final String adPicUrl;
  AdBanner({this.adPicUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(adPicUrl),
    );
  }
}

//经理电话组件
class LeaderPhone extends StatelessWidget {

  final String leaderImageUrl;
  final String leaderPhone;
  LeaderPhone({this.leaderImageUrl, this.leaderPhone});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _phoneClicked,
        child: Image.network(leaderImageUrl),
      ),
    );
  }

  void _phoneClicked() async {
    String url = 'tel:'+leaderPhone;
//  String url = 'https://www.jianshu.com/u/c9dfc3858121';
    if(await canLaunch(url)){
      await launch(url);
    }else{
      throw '拨打电话url异常';
    }
  }
}

//商品推荐
class Recommend extends StatelessWidget {

  //数据源数组
  final List recommendList;
  Recommend({this.recommendList});

  //接下来需要新建三个组件：商品推荐标题、每一个商品item、横向排列item

  //商品推荐标题
  Widget _titleWidget(){
    return Container(
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 5.0, 2.0),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.black12, width: 0.5)
        )
      ),
      child: Text('商品推荐',style: TextStyle(color: Colors.pink),),
    );
  }

  //每一个商品item
  Widget _item(int index){
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              left: BorderSide(color: Colors.black12, width: 0.5)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommendList[index]['image']),
            Text('￥${recommendList[index]['mallPrice']}'),
            Text(
              '￥${recommendList[index]['price']}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }

  //横向排列item
  Widget _listView(){
    return Container(
      height: ScreenUtil().setHeight(300),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index){
          return _item(index);
        },
        itemCount: recommendList.length,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    if (recommendList.length<3){
      //添加一个，为了好看
      recommendList.add(recommendList.last);
    }

    return Container(
      height: ScreenUtil().setHeight(350),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _listView()
        ],
      ),
    );
  }
}
