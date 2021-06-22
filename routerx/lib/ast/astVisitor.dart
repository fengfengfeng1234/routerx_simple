import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/ast/ast.dart';

class AstVisitor extends GeneralizingAstVisitor<Map> {
  Map? visitNode(AstNode node) {}

  String _safelyVisitToken(Token? token) {
    return token == null ? '' : token.lexeme;
  }


  /// 遍历节点
  Map? _safelyVisitNode(AstNode? node) {
    if (node != null) {
      return node.accept(this);
    }
    return null;
  }

  /// 遍历节点列表
  List<Map> _safelyVisitNodeList(NodeList<AstNode> nodes) {
    List<Map> maps = [];
    if (nodes != null) {
      int size = nodes.length;
      for (int i = 0; i < size; i++) {
        var node = nodes[i];
        if (node != null) {
          var res = node.accept(this);
          if (res != null) {
            maps.add(res);
          }
        }
      }
    }
    return maps;
  }


  Map _buildAssignmentExpression(
      Map? leftHandSide, Map? rightHandSide, String? operator) =>
      {
        AstKey.TYPE: AstType.AssignmentExpression,
        AstKey.LeftExpression: leftHandSide,
        AstKey.RightExpression: rightHandSide,
        AstKey.Operator: operator
      };





  //构造标识符定义
  Map _buildSimpleIdentifier(String name) =>
      {AstKey.TYPE: AstType.SimpleIdentifier, AstKey.Name: name};

  //构造运算表达式结构
  Map _buildBinaryExpression(Map? left, Map? right, String? lexeme) => {
    AstKey.TYPE: AstType.BinaryExpression,
    AstKey.Operator: lexeme,
    AstKey.LeftExpression: left,
    AstKey.RightExpression: right
  };









  Map _buildStringLiteral(String value) =>
      {AstKey.TYPE: AstType.StringLiteral, AstKey.Value: value};




  Map _buildImplementsClause(List<Map> implementList) =>
      {AstKey.TYPE: AstType.ImplementsClause, AstKey.TypeName: implementList};








  @override
  Map visitFieldDeclaration(FieldDeclaration node) {
    return {
      AstKey.TYPE: AstType.FieldDeclaration,
      AstKey.MetaData: _safelyVisitNodeList(node.metadata),
      AstKey.AbstractKeyword: _safelyVisitToken(node.abstractKeyword),
      AstKey.ExternalKeyword: _safelyVisitToken(node.externalKeyword),
      AstKey.StaticKeyword: _safelyVisitToken(node.staticKeyword),
      AstKey.DeclarationList: _safelyVisitNode(node.fields)
    };
  }



  @override
  Map visitTypeParameterList(TypeParameterList node) {
    return {
      AstKey.TYPE: AstType.TypeParameterList,
      AstKey.NodeList: _safelyVisitNodeList(node.typeParameters)
    };
  }



  @override
  Map visitCompilationUnit(CompilationUnit node) {
    return {
      AstKey.TYPE: AstType.Program,
      AstKey.DirectiveLIST: _safelyVisitNodeList(node.directives),
      AstKey.DeclarationList: _safelyVisitNodeList(node.declarations),
      AstKey.Prefix: _safelyVisitNode(node.scriptTag),
    };
  }








  @override
  Map visitAssignmentExpression(AssignmentExpression node) {
    return _buildAssignmentExpression(_safelyVisitNode(node.leftHandSide),
        _safelyVisitNode(node.rightHandSide), node.operator.stringValue);
  }

  @override
  Map? visitBlockFunctionBody(BlockFunctionBody node) {
    return _safelyVisitNode(node.block);
  }

  @override
  Map visitVariableDeclaration(VariableDeclaration node) {
    return {
      AstKey.TYPE: AstType.VariableDeclaration,
      AstKey.MetaData: _safelyVisitNodeList(node.metadata),
      AstKey.Identifier: _safelyVisitNode(node.name),
      AstKey.Expression: _safelyVisitNode(node.initializer),
    };
  }

  @override
  Map? visitVariableDeclarationStatement(VariableDeclarationStatement? node) {
    return _safelyVisitNode(node?.variables);
  }

  @override
  Map visitVariableDeclarationList(VariableDeclarationList node) {
    return {
      AstKey.TYPE: AstType.VariableDeclarationList,
      AstKey.MetaData: _safelyVisitNodeList(node.metadata),
      AstKey.Keyword: _safelyVisitToken(node.keyword),
      AstKey.LateKeyword: _safelyVisitToken(node.lateKeyword),
      AstKey.TypeName: _safelyVisitNode(node.type),
      AstKey.DeclarationList: _safelyVisitNodeList(node.variables),
    };
  }

  @override
  Map visitSimpleIdentifier(SimpleIdentifier node) {
    return _buildSimpleIdentifier(node.name);
  }

  @override
  Map visitBinaryExpression(BinaryExpression node) {
    return _buildBinaryExpression(_safelyVisitNode(node.leftOperand),
        _safelyVisitNode(node.rightOperand), _safelyVisitToken(node.operator));
  }


  @override
  Map? visitFunctionDeclarationStatement(FunctionDeclarationStatement node) {
    return _safelyVisitNode(node.functionDeclaration);
  }



  @override
  Map visitTypeName(TypeName node) {
    return {
      AstKey.TYPE: AstType.TypeName,
      AstKey.Name: node.name.name,
      AstKey.TypeParameterList: _safelyVisitNode(node.typeArguments)
    };
  }





  @override
  visitClassDeclaration(ClassDeclaration node) {
    return {
      AstKey.TYPE: AstType.ClassDeclaration,
      AstKey.Identifier: _safelyVisitNode(node.name),
      AstKey.SuperClause: _safelyVisitNode(node.extendsClause),
      AstKey.ImplementsClause: _safelyVisitNode(node.implementsClause),
      AstKey.WithClause: _safelyVisitNode(node.withClause),
      AstKey.MetaData: _safelyVisitNodeList(node.metadata),
      AstKey.DeclarationList: _safelyVisitNodeList(node.members),
    };
  }

  @override
  visitSimpleStringLiteral(SimpleStringLiteral node) {
    return _buildStringLiteral(node.value);
  }




  @override
  visitLabel(Label node) {
    return _safelyVisitNode(node.label);
  }

  @override
  visitExtendsClause(ExtendsClause node) {
    return _safelyVisitNode(node.superclass);
  }

  @override
  visitImplementsClause(ImplementsClause node) {
    return _buildImplementsClause(_safelyVisitNodeList(node.interfaces));
  }

  @override
  visitWithClause(WithClause node) {
    return {
      AstKey.TYPE: AstType.WithClause,
      AstKey.TypeName: _safelyVisitNodeList(node.mixinTypes)
    };
  }


}

class AstKey {
  //keys
  static const String TYPE = 'type';


  static const String NodeList = 'nodeList';

  static const String DirectiveLIST = 'directiveList';

  static const String DeclarationList = 'declarationList';

  static const String TypeName = 'typeName';

  static const String Expression = 'expression';
  static const String ExpressionList = 'expressionList';
  static const String LeftExpression = 'leftExpression';
  static const String RightExpression = 'rightExpression';



  static const String Operator = 'operator';

  static const String Identifier = 'identifier';
  static const String Prefix = 'prefix';

  static const String Name = 'name';
  static const String Value = 'value';

  static const String TypeParameterList = 'typeParameterList';



  static const String SuperClause = 'superClause';
  static const String ImplementsClause = 'implementsClause';
  static const String WithClause = 'withClause';
  static const String MetaData = 'metadata';

  static const String Keyword = 'keyword';
  static const String LateKeyword = 'lateKeyword';
  static const String ExternalKeyword = 'externalKeyword';
  static const String AbstractKeyword = 'abstractKeyword';
  static const String StaticKeyword = 'staticKeyword';








}

class AstType {
  static const String Program = 'Program';
  static const String AssignmentExpression = 'AssignmentExpression';
  static const String VariableDeclaration = 'VariableDeclaration';
  static const String VariableDeclarationList = 'VariableDeclarationList';
  static const String SimpleIdentifier = 'SimpleIdentifier';
  static const String BinaryExpression = 'BinaryExpression';
  static const String TypeName = 'TypeName';
  static const String ClassDeclaration = 'ClassDeclaration';
  static const String StringLiteral = 'StringLiteral';
  static const String ImplementsClause = 'ImplementsClause';
  static const String FieldDeclaration = 'FieldDeclaration';


  static const String TypeParameterList = 'TypeParameterList';
  static const String WithClause = 'WithClause';
}