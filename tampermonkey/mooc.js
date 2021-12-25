// ==UserScript==
// @name         mooc
// @namespace    https://github.com/NotFaceGUI
// @version      0.2
// @description  简单的刷课软件
// @match        https://mooc.icve.com.cn/study/workExam/*
// @require      https://code.jquery.com/jquery-3.1.1.min.js
// @updateURL    https://github.com/NotFaceGUI/script/blob/main/tampermonkey/mooc.js
// @downloadURL  https://github.com/NotFaceGUI/script/blob/main/tampermonkey/mooc.js
// @grant        GM_xmlhttpRequest
// @grant        GM_setValue
// @grant        GM_getValue
// @connect      *
// ==/UserScript==


(function () {
    'use strict';
    // 获取当前页面的url和参数
    let urlParameter = location.search.slice(1);
    let url = location.pathname;

    // 课程id,自行填写
    let courseOpenId = "4ljtabatvkjjmrkllppccg";

    // 试卷id
    let workExamId = "";

    // 类型，默认为测验
    let workExamType = 0;

    // 全局答案数组
    let answerGlobal = [];

    // 完成标记
    let flag = false;

    // 页面加载完成执行
    $(document).ready(function () {
        url = url.substring(url.lastIndexOf('/') + 1);

        if (url === "testWork.html" || url === "homeWork.html") {
            // 将当前页的列数设置成最大

            window.location.replace(window.location.href + "#pageSize=5000&page=1");
            let b = setInterval(() => {
                let itemArr = $(".np-hw-li .np-hw-score");
                if (itemArr.length != 0) {
                    clearInterval(b);

                    let index = 0
                    for (let i = 0; i < itemArr.length; i++) {
                        // 如果没有做则跳转到当前页面内
                        if ($(".np-hw-li .np-hw-score")[i].innerText == "未做") {
                            // 执行代码
                            $(".np-hw-control a")[i].click()
                        } else {
                            index += 1;
                        }
                    }

                    if (index == itemArr.length) {
                        alert("刷课完毕");
                        getworkExamId();

                        if (workExamType != 1) {
                            window.location.replace(`https://mooc.icve.com.cn/study/workExam/testWork/testWork.html?workExamType=1&courseOpenId=${courseOpenId}#pageSize=5000&page=1`);
                        } else {
                            window.location.replace(`https://mooc.icve.com.cn/study/workExam/homeWork/homeWork.html?workExamType=0&courseOpenId=${courseOpenId}#pageSize=5000&page=1`);
                        }
                    }


                }
            }, 500);
        }

        // 进入选择
        if (url === "detail.html") {
            setInterval(() => {
                $(".am-btn.am-btn-primary.studoHomework")[0].click() //点击测验
            }, 1000);
        }

        // 进入答题界面
        if (url === "preview.html") {
            getworkExamId();
            // 获取答案 存入全局答案变量中
            getAnswer();

            let click = setInterval(() => {
                if (flag) {
                    clearInterval(click);
                    sleep(1000).then(() => {
                        $("#submitHomeWork")[0].click();
                    })

                    sleep(2500).then(() => {
                        $(".sgBtn.ok")[0].click();

                        if (workExamType == 1) {
                            window.location.replace("https://mooc.icve.com.cn/study/workExam/testWork/testWork.html?workExamType=1&courseOpenId=4ljtabatvkjjmrkllppccg#pageSize=5000&page=1");
                        } else {
                            window.location.replace("https://mooc.icve.com.cn/study/workExam/homeWork/homeWork.html?workExamType=0&courseOpenId=4ljtabatvkjjmrkllppccg#pageSize=5000&page=1");
                        }
                    })
                }

            }, 200)
        }
    });

    function getWorkExamAnswer() {
        // 发送ajax请求获取答案
        GM_xmlhttpRequest({
            method: "post",
            url: 'https://mooc.icve.com.cn/study/workExam/workExamPreview',
            data: `courseOpenId=${courseOpenId}&workExamId=${workExamId}&workExamType=${workExamType}`,
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            },
            onload: function (res) {
                let json = JSON.parse(res.response);
                answer = JSON.parse(json.workExamData).questions;
            },
            onerror: function (err) {
                console.log('error')
                console.log(err)
            }
        });
    }

    let answer;

    /**
     * @param {Array} answer
     * 处理答案，返回简化的数据
     */
    function treatmentAnswer(answer) {
        // 存放答案下标的数组
        answer.forEach(item => {
            item.answerList.forEach((em, index) => {
                if (em.IsAnswer.toLowerCase() === "true") {
                    answerGlobal.push(index);
                }
            })

        });
    }

    function getAnswer() {
        if (workExamId !== "") {
            // 发送ajax请求获取答案
            getWorkExamAnswer();

            let json = setInterval(() => {
                if (answer != undefined) {
                    clearInterval(json);
                    console.log(answer);
                    console.log("======")
                    treatmentAnswer(answer);
                    // 设置一个定时函数，当未请求到答案时一直执行
                    // 获取完答案自动做题
                    console.log(answerGlobal);
                    let arr = $(".e-a");
                    let current = 0;
                    for (let index = 0; index < (arr.length / 4); index++) {
                        arr[answerGlobal[index] + current].click();
                        current += 4
                    }
                    flag = true;
                }
            }, 200)
        }
    }

    function getworkExamId() {
        urlParameter.split("&").forEach(item => {
            if (item.indexOf("workExamId") != -1) {
                workExamId = item.split('=')[1];
            }
            if (item.indexOf("workExamType") != -1) {
                workExamType = item.split('=')[1];
            }
        });
    }

    function sleep(time) {
        return new Promise((resolve) => setTimeout(resolve, time));
    }
})();