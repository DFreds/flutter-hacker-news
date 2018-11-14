import 'dart:async';
import 'package:news/src/models/item_model.dart';
import 'package:news/src/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class CommentsBloc {
  final _repository = Repository();
  final _commentsOutput = BehaviorSubject<Map<int, Future<ItemModel>>>();
  final _commentsFetcher = PublishSubject<int>();

  // Getters to streams
  Observable<Map<int, Future<ItemModel>>> get itemWithComments =>
    _commentsOutput.stream;

  // Getters to sinks
  Function(int) get fetchItemWithComments => _commentsFetcher.sink.add;

  CommentsBloc() {
    _commentsFetcher.stream.transform(_commentsTransformer()).pipe(_commentsOutput);
  }

  _commentsTransformer() {
    return ScanStreamTransformer<int, Map<int, Future<ItemModel>>>(
      (Map<int, Future<ItemModel>> cache, int id, int index) {
        cache[id] = _repository.fetchItem(id);
        cache[id].then((ItemModel itemModel) {
          itemModel.kids.forEach((kidId) => fetchItemWithComments(kidId));
        });

        return cache;
      },
      <int, Future<ItemModel>>{}
    );
  }

  dispose() {
    _commentsOutput.close();
    _commentsFetcher.close();
  }
}