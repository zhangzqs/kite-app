import axios from 'axios'
import $ from 'cheerio'

import { parseInt } from 'lodash'
import { BOOK_IMAGE_INFO_URL, SEARCH_URL } from '@/constants/crawler/library'

export enum SearchWay {
    // 按任意词查询
    Any = '',
    // 标题名
    Title = 'title',
    // 正题名：一本书的主要名称
    TitleProper = 'title200a',
    // ISBN号
    Isbn = 'isbn',
    // 著者
    Author = 'author',
    // 主题词
    SubjectWord = 'subject',
    // 分类号
    ClassNo = 'class',
    // 控制号
    CtrlNo = 'ctrlno',
    // 订购号
    OrderNo = 'orderno',
    // 出版社
    Publisher = 'publisher',
    // 索书号
    CallNo = 'callno',
}

export enum SortWay {
    // 匹配度
    MatchScore = 'score',
    // 出版日期
    PublishDate = 'pubdate_sort',
    // 主题词
    Subject = 'subject_sort',
    // 标题名
    Title = 'title_sort',
    // 作者
    Author = 'author_sort',
    // 索书号
    CallNo = 'callno_sort',
    // 标题名拼音
    Pinyin = 'pinyin_sort',
    // 借阅次数
    LoanCount = 'loannum_sort',
    // 续借次数
    RenewCount = 'renew_sort',
    // 题名权重
    TitleWeight = 'title200Weight',
    // 正题名权重
    TitleProperWeight = 'title200aWeight',
    // 卷册号
    Volume = 'title200h',
}

export enum SortOrder {
    Asc = 'asc',
    Desc = 'desc',
}

/**
 * 找到src字符串中第一个逗号结尾的整数，并解析成number
 * 例如：
 * '123,abc' 将返回数字123
 * '12,34' 将返回数字12
 *
 * @param src
 */
const parseIntWithComma = (src: string): number =>
    parseInt(/(\d+,?)+/.exec(src)![0].split(',').join(''))

/**
 * 根据ISBN字符串搜索图书图片信息
 * 注意：返回的字典中key为isbn号(消除了所有的isbn中的'-'符号，仅保留数字)
 * 若待查找的isbn在key中不存在，那就表示查不到
 * @param isbnStr isbn字符串,如果有多个isbn，使用逗号分割
 * @return Promise<BookImageSearchResult> 返回一个key为isbn号的字典
 */
const searchBookImageByIsbnStr = async (isbnStr: string): Promise<BookImageSearchResult> => {
    const queryParams = {
        glc: 'U1SH021060',
        cmdACT: 'getImages',
        type: '0',
        isbns: isbnStr,
    }

    const response = await axios.get(BOOK_IMAGE_INFO_URL, {
        params: queryParams,
    })

    let responseJsonStr = response.data.trim()
    responseJsonStr = responseJsonStr.substring(1, responseJsonStr.length - 1)

    const bookImageInfoArray: BookImageInfo[] = JSON.parse(responseJsonStr)['result']

    let bookImageInfoDict: BookImageSearchResult = {}
    bookImageInfoArray.forEach((bookImageInfo) => {
        bookImageInfoDict[bookImageInfo.isbn] = bookImageInfo
    })
    return bookImageInfoDict
}

/**
 * 根据ISBN数组搜索所有的图书图片信息
 * @param isbnArray ISBN数组
 */
export const searchBookImageByIsbnArray = async (
    isbnArray: string[]
): Promise<BookImageSearchResult> => {
    return searchBookImageByIsbnStr(isbnArray.join(','))
}

export const searchBookImageByBookArray = async (
    bookArray: Book[]
): Promise<BookImageSearchResult> => {
    return searchBookImageByIsbnStr(bookArray.map((v) => v.isbn).join(','))
}

export const searchBook = async (request: SearchLibraryRequest): Promise<SearchLibraryResult> => {
    const queryParams = {
        q: request.keyword,
        searchType: 'standard',
        isFacet: 'true',
        view: 'standard',
        searchWay: request.searchWay,
        rows: request.rows.toString(),
        sortWay: request.sortWay,
        sortOrder: request.sortOrder,
        // 变量名为保持与图书馆系统参数一致, 禁止修改并忽略 IDE 警告
        hasholding: '1',
        searchWay0: 'marc',
        logical0: 'AND',
        page: request.page.toString(),
    }

    const response = await axios.get(SEARCH_URL, {
        params: queryParams,
    })

    const document = $(response.data)

    const bookList = $('.resultTable > tbody:nth-child(1) > tr', document)
        .map((index, element): Book => {
            const bookCoverImage = $('.bookcover_img', element)
            const getBookInfo = (selector: string) => $(selector, element).html()?.trim()!

            const author = getBookInfo('.author-link')
            const bookId = bookCoverImage.attr('bookrecno')!
            const isbn = bookCoverImage.attr('isbn')!
            const callNo = getBookInfo('.callnosSpan')
            const publishDate = getBookInfo(
                'td:nth-child(4) > div:nth-child(1) > div:nth-child(3)'
            ).split('出版日期:')[1]
            const publisher = getBookInfo('.publisher-link')
            const title = getBookInfo('.title-link')

            return { author, bookId, isbn, callNo, publishDate, publisher, title }
        })
        .get()

    const currentPage = parseInt($('div.meneame:nth-child(4) > b:nth-child(4)', document).text())
    const resultNumAndTime = $('#search_meta > div:nth-child(1)', document).text()
    const totalPages = parseIntWithComma(
        $('div.meneame:nth-child(4) > span:nth-child(1)', document).text()
    )
    const resultCount = parseIntWithComma(resultNumAndTime)
    const useTime = parseFloat(/检索时间: (\d+(?:\.\d+)?)/.exec(resultNumAndTime)![1])

    return {
        resultCount,
        useTime,
        currentPage,
        totalPages,
        bookList,
    }
}
